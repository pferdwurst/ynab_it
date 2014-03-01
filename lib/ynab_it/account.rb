module YnabIt
  class Account
    # Defines a bank/institution account struct

    attr_accessor :id, :name, :account_id, :nickname, :institution_id, :institution, :username, :password, :category, :customer_id, :downloads_path, :raw_dir
    class << self
      def load(customer_id, raw_dir, formatted_dir, hsh)
        # assume the argument is a hash
        a = Account.new
        # Fail if either of these are empty
        a.account_id = hsh[:account_id] || (raise ArgumentError, "Missing account_id")
        a.customer_id = customer_id || (raise ArgumentError, "Missing customer_id")

        a.id = hsh[:id] || "<id>"
        a.name = hsh[:name] || "<name>"
        a.nickname = hsh[:account_nickname]
        a.institution_id = hsh[:institution_id] ||  (raise ArgumentError, "Missing institution_id")
        a.username = hsh[:username] || "<username>"
        a.password = hsh[:password] || "<password>"
        a.category = hsh[:category] || "<category>"
        a.downloads_path = formatted_dir
        a.raw_dir = raw_dir

        # Retrieve the institution information.  In the future this can be stored and normalized
        begin
          inst =  YnabIt.institutions.find { |i| i[:institution_id] ==  hsh[:institution_id] }
          a.institution = Institution.load(inst)
        rescue StandardError => e
          puts "Failed to load institution data for id #{hsh[:institution_id]}: #{e}"
        end

        a
      end
    end

    def show()
      history = downloader.history
      f = Rainbow.new
      str = f.wrap("Account #{account_id}\n").bright.blue  +
      "\t" + f.wrap("name:").yellow + "\t" + f.wrap("#{name}").green + "\n" +
      "\t" + f.wrap("nickname:").yellow + "\t" + f.wrap("#{nickname}").green + "\n" +
      "\t" + f.wrap("category:").yellow + "\t" + f.wrap("#{category}").green + "\n" +
      "\t" + f.wrap("institution:").yellow + "\n" + institution.show(f) + "\n" +
      "\t" + f.wrap("account_id:").yellow + "\t#{account_id} \n" +
      "\t" + f.wrap("downloads_path:").yellow + "\t" + f.wrap("#{path}").underline + "\n" + history.info

      print str
    end

    # Path to formatted/processed downloads
    def path
      download_path = File.join downloads_path, customer_id, (account_id.nil? ? "account_id" : account_id)
    end

    def downloader
      dwnl = TxDownloader.new customer_id,  account_id
      dwnl.formatted_base = path
      dwnl.raw_base = raw_dir
      return dwnl
    end

  end

end
