require 'ostruct'
require 'yaml'
require 'pp'

module YnabIt
  class Customer < YnabIt::Base

    attr_accessor :customer_id, :accounts
    def initialize(c_id)
      super()

      @customer_id  = c_id
      @client.instance_variable_set(:@customer_id, c_id)
      @accounts = {}

      # Load the accounts
      load_account_list

      @log.info("The client is initialized #{@client.inspect}")
    end

    # File containting list of accounts belonging to a customer_id
    # This is not configuration info but comes from Intuit
    # The accounts can be loaded from a file containing the AggCat response
    # so as to not have to repeatedly query the API

    def load_account_list
      dname = self.raw_dir
      fname = File.join(dname, "accounts.#{customer_id}")

      if !Dir.exist?(dname)
        Dir.mkdir(dname)
      end

      if (!File.exist?(fname) )
        # It appears that the account list was not written to disk
        # Fetch the list from the API and persist
        @log.debug("Fetching account details from the API and writing to #{fname}")
        begin
          File.write(fname,  @client.accounts)
        rescue StandardError => e
          @log.error("Failed to fetch the account details from the api: #{e}")
        end
      end

      data = File.open(fname).read

      parse_account_list(data)

    rescue => e
      @log.error("Failed to load account list from #{fname}: #{e}")
      raise
      end

    # Get accounts for customer_id from Intuit
    # Downloads the raw output to file
    # All subsequent calls in txhe same day will load
    # from the raw downloaded file (unless forced not to)
    def parse_account_list(raw_details)

      if (raw_details.class == String)
        l1 = OpenStruct.new eval(raw_details)
      else
        l1 = OpenStruct.new raw_details
      end

      # nested structs
      l2 = OpenStruct.new l1.result
      l3 = OpenStruct.new l2.account_list

      @ACCT_TYPES = [ :credit_account, :banking_account, :loan_account]

      @ACCT_TYPES.each do |at|
        account_type = eval("l3." + at.to_s)
        unless account_type.nil?
          account_type.each do |l|
            acct_hash = l.merge({:category => at.to_s})
            acct = Account.load(customer_id, raw_dir, formatted_dir, acct_hash)
            @accounts[acct.account_id] =  acct
          end
        end
      end
     
    end

    def show_accounts(acct_hsh = accounts)
      #PP.pp(accounts, $>,  maxwidth = 50)
      acct_hsh.values.each do |a|
        a.show
      end
    end
  #----------------------
  end

end