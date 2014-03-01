#require File.join(File.expand_path(File.dirname(__FILE__)), "date_utils")
require '/Users/tanya/workspace/ynab_it/lib/ynab_it/the_date_utils'

module YnabIt
  class DownloadRange < Range
    #include DateUtils

    attr_accessor :s1, :s2
    
    
    class << self
      def from_file(fname)
        begin
        # parse file name
           account_id, beginning, ending, ext = fname.split(".", 4)
          #   raise ArgumentError "File #{fname} does not have the correct syntax"
# 
           s1 = DateTime.strptime(beginning, FileName.FILE_DATE_FORMAT)
           s2 = DateTime.strptime(ending, FileName.FILE_DATE_FORMAT)
           DownloadRange.new(s1, s2)
         rescue => e
           YnabIt.logger.error("Could not parse dates from file #{fname}")
           return DownloadRange.new
        end
      end
    end
    
    def s1
      return first
    end

    def s2
      return last
    end
    
    def empty?
      s1 == s2
    end
    
    def spans_years?
     s1.year != s2.year
    end
   
   def to_s
     "[ #{s1.strftime("%b %d, %Y")} - #{s2.strftime("%b %d, %Y")} ]"
   end

  end

 

end