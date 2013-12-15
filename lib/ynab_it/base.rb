module YnabIt
  class Base

    PRGM_DIR    = File.expand_path("../../..", __FILE__)
    
    CLIENT_CONF = File.join PRGM_DIR , "conf/ynab_it.conf"
    ACCT_CONF   = File.join PRGM_DIR , "conf/accts.conf.yml"

    attr_accessor :client, :log
    
    def initialize
      client_conf = YAML.load_file(CLIENT_CONF)
      

      # alternatively, specify configuration options when instantiating an Aggcat::Client
      @client = Aggcat::Client.new(
        :issuer_id =>  client_conf["client"]["issuer_id"],
        :consumer_key => client_conf["client"]["consumer_key"],
        :consumer_secret => client_conf["client"]["consumer_secret"],
        :certificate_path => File.join( PRGM_DIR, client_conf["client"]["certificate_path"]),
       # This default value needs to be overwritten 
        :customer_id => "customer_id"
      )
      
      @log = YnabIt.logger
      
    end

    


  end

end
