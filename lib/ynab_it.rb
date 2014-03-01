require 'ostruct'
require 'date'
require 'pp'
require 'aggcat'
require 'yaml'
require 'date'
require 'rainbow'
require 'formatador'


# Logger
require 'logger'

module YnabIt
  NAME = "YnabIt"
  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'ynab_it')
  LOG_DIR = File.join(File.expand_path("../..", __FILE__), "log")

  FOLDER_DATE_FORMAT = "%Y%m%d"
  
  
  
  def YnabIt.institutions
    @@institutions ||= []
  end
  
  
  def YnabIt.logger
    
    @@logger ||= nil
    if (@@logger.nil?)
    unless Dir.exist?(LOG_DIR)
      Dir.mkdir(LOG_DIR)
     end
    
       @@logger = Logger.new(File.join(LOG_DIR, "ynab_it.log"), "daily")
       @@logger.formatter = proc do |severity, datetime, progname, msg|
           "YnabIt: #{datetime}: #{msg}\n"
        end
        @@logger
      else
        @@logger
      end
  end
  
  # Creates a DateTime object from a string
  # in the format of "%Y%m%d"
  def YnabIt.to_date(string_date)
     DateTime.strptime(string_date, FOLDER_DATE_FORMAT)
  end


  # String representation of DateTime object
  # coforming to the directory naming convention being used
  def YnabIt.to_datestr(datetime)
    datetime.strftime( FOLDER_DATE_FORMAT )
  end



 def YnabIt.load_institutions(client, force = false)
     # load institution data
      output_file = File.join(File.join(File.expand_path("../..", __FILE__), "downloads/raw"), "institutions")
      
      if (!File.exist?(output_file)  or force)
        # Fetch the list from the API and persist
        @@logger.info("Fetching institution list from the API and writing to #{output_file}")
        begin
          @@institutions = client.institutions
          File.open(output_file, "wb") { |f| Marshal.dump(  @institutions, f) }
        rescue StandardError => e
          @@logger.error( "Failed to fetch the institutions from the api: #{e}" )
        end
      else
        @@logger.info("Loading the institutions from file" )
        
         response = File.open(output_file, "rb") { |f| Marshal.load(f) }
         if response[:status_code] == "200"
            @@institutions = response[:result][:institutions][:institution]
         else
           @@logger.error("problem loading the institutions file #{response[:status_code]}" )
         end
         
      end
   end
  


  ##
  # Require YnabIt base files
  %w{
base
download_range

account
customer
file_name
download
exceptions
tx_downloader
download_history
version
process
etl
institution
}.each {|lib| require File.join(LIBRARY_PATH, lib) }


  
end
