module YnabIt
  class Base

    PRGM_DIR    = File.expand_path("../../..", __FILE__)
    DOWNLOADS_DIR = File.join PRGM_DIR , "downloads"
    
    CLIENT_CONF = File.join PRGM_DIR , "conf/ynab_it.conf"
    ACCT_CONF   = File.join PRGM_DIR , "conf/accts.conf.yml"

    attr_accessor :client, :log, :settings, :institutions
    #
    #
    def initialize
      conf = YAML.load_file(CLIENT_CONF)
      client_conf = conf["client"]
      customer_conf = conf["customer"]

      # alternatively, specify configuration options when instantiating an Aggcat::Client
      @client = Aggcat::Client.new(
        :issuer_id =>  client_conf["issuer_id"],
        :consumer_key => client_conf["consumer_key"],
        :consumer_secret => client_conf["consumer_secret"],
        :certificate_path => File.join( PRGM_DIR, client_conf["certificate_path"]),
       # This default value needs to be overwritten
        :customer_id => "customer_id"
      )

      @settings = CustomerConfigSettings.new(customer_conf["customer_id"], customer_conf["download_dir"])
     
      YnabIt.load_institutions(@client)
      @log = YnabIt.logger
     end




    def method_missing(m, *args, &block)
      puts "There's no method [#{m}] taking arguments #{args}"
    end

    def download_dir
      if @settings.download_dir.nil?
        return DOWNLOADS_DIR
      else
      return @settings.download_dir
      end
    end

    def formatted_dir
      return File.join download_dir , "formatted"
    end

    def raw_dir
      return File.join download_dir , "raw"
    end

  
  end

  class CustomerConfigSettings
    attr_accessor :customer_id, :download_dir
    def initialize(customer_id, download_dir)
      @customer_id = customer_id
      @download_dir = download_dir

    end

  end
end
