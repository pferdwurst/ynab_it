
module YnabIt
  class Account 
    # Defines a bank/institution account struct

    attr_accessor :name, :id, :institution_id, :institution, :username, :password, :category, :customer_id, :account_id, :downloads_path, :raw_dir
  
   
    
    class << self
      def load(customer_id, raw_dir, formatted_dir, hsh)
        # assume the argument is a hash
        a = Account.new
        # Fail if either of these are empty
        a.account_id = hsh[:account_id] || (raise ArgumentError, "Missing account_id")
        a.customer_id = customer_id || (raise ArgumentError, "Missing customer_id")

        a.name = hsh[:name] || "<name>"
        a.id = hsh[:id] || "<id>"
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
    
    def to_s()
"Account
   name:             #{name}
   institution:      #{institution}
   account_id:       #{account_id}
   downloads_path:   #{path}
   download_history: #{downloader.show_history}
"
    end

    # Path to formatted/processed downloads
    def path
      download_path = File.join downloads_path, customer_id, (account_id.nil? ? "account_id" : account_id)
    end

    def downloader
      dwnl = TxDownloader.new customer_id,  account_id
      dwnl.download_path = path
      dwnl.raw_path = raw_dir
      return dwnl
    end

  end
  
end
