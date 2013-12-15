
module YnabIt
  class Account

    # Defines a bank/institution account struct

    attr_accessor :name, :id, :institution_id, :username, :password, :category, :customer_id, :account_id, :downloads_path
    class << self
      def load(customer_id, hsh)

        # assume the argument is a hash
        a = Account.new
        # Fail if either of these are empty
        a.account_id = hsh[:account_id] || (raise ArgumentError, "Missing account_id")
        a.customer_id = customer_id || (raise ArgumentError, "Missing customer_id")

        a.name = hsh[:name]
        a.id = hsh[:id]
        a.institution_id = hsh[:institution_id]
        a.username = hsh[:username]
        a.password = hsh[:password]
        a.category = hsh[:category]
        # downloads are read from elsewhere

        a
      end
    end

   
    def to_s()
      puts "
         Account 
            name: #{name},
           downloads_path: #{path}"       
    end

    # Path to formatted/processed downloads
    def path
      download_path = File.join TxDownloader.FORMATTED_DIR, customer_id, (account_id.nil? ? "account_id" : account_id)
    end

    def downloader
      dwnl = TxDownloader.new customer_id,  account_id
      dwnl.download_path = path
      return dwnl
    end

  end
end
