require 'aggcat'
require 'json'
require 'yaml'
require './account'
require './tx_downloader'

module Getit
  class Base

    # !!! TODO !!!
    # the dir structure should be read from the downloader path

    PRGM_DIR = File.expand_path("..", Dir.pwd)

    CLIENT_CONF = File.join PRGM_DIR , "conf/client.conf.yml"
    CUSTOMER_CONF = File.join PRGM_DIR, "conf/customer.conf.yml"
    ACCT_CONF = File.join PRGM_DIR , "conf/accts.conf.yml"

    attr_accessor :client, :downloader
    
    
    def initialize
      client_conf = YAML.load_file(CLIENT_CONF)

      # alternatively, specify configuration options when instantiating an Aggcat::Client
      self.client = Aggcat::Client.new(
        :issuer_id =>  client_conf["issuer_id"],
        :consumer_key => client_conf["consumer_key"],
        :consumer_secret => client_conf["consumer_secret"],
        :certificate_path => client_conf["certificate_path"]
       # This is moved to the Customer
       # :customer_id => client_conf["customer_id"]
      )
    end

    def load_accounts
      # Pull in account information
      cnf =  YAML.load_file( ACCT_CONF )

      cnf.each do |k,v|

        if k == "customer_id"
        customer_id = v
        end

        if k == "categories"
          v.each do |category, v1|

            print "Loading accounts types: #{category}\n"

            v1.each do |v2|
              acct = Account.load(v2)
              acct.category = category
              acct.customer_id = customer_id

              @all_accounts.push acct

            end
          end
        end
      end

    end

    def client
      @client
    end

    def username
      "username"
    end

    def password
      "password"
    end

  end

end
