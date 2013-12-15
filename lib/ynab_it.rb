require 'ostruct'
require 'date'
require 'pp'
require 'aggcat'
require 'yaml'
require 'date'

# Logger
require 'logger'

module YnabIt
  NAME = "YnabIt"
  LIBRARY_PATH = File.join(File.dirname(__FILE__), 'ynab_it')

  FOLDER_DATE_FORMAT = "%Y%m%d"
  
    def YnabIt.logger
       unless Dir.exist?("log"); Dir.mkdir("log"); end
    
       logger = Logger.new("log/ynab_it.log", "daily")
       logger.formatter = proc do |severity, datetime, progname, msg|
      "YnabIt: #{datetime}: #{msg}\n"
    end
    return logger
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

  ##
  # Require YnabIt base files
  %w{
account
base
customer
tx_downloader
version
}.each {|lib| require File.join(LIBRARY_PATH, lib) }


  
end
