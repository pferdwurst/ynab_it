require 'range_with_gaps'

module YnabIt
  class DownloadHistory
    #  include YnabIt::TheDateUtils

    # Holds a history of tx downloads
    attr_accessor :id, :download_path, :downloads, :latest_download, :download_dates, :account_id
    def initialize(account_id, dpath)
      self.download_path = dpath
      self.download_dates = []
      self.account_id = account_id
      self.downloads = inventory_downloads
    end

    def inventory_downloads
      downloads = []
      if Dir.exist?(download_path)
        Dir.entries(download_path).each do |start_date|
          unless (start_date == "." or start_date == "..")
            begin
              download_dates.push(YnabIt.to_date(start_date))

              path = File.join download_path, start_date
              Dir.entries(path ).each do |fname|
                unless (fname == "." or fname == "..")
                  dwld = Download.new fname
                downloads.push(dwld)
                end

              end
            rescue ArgumentError => e
              YnabIt.logger.debug( "Skipping directory #{start_date}: #{e}")
            end
          end
        end
        unless downloads.empty?
          downloads.sort { |a,b| a.date_range.first <=> b.date_range.first }
        end
      end
      return downloads
    end
    
    
    # Return the ranges of dates for which there are no downloads
    # This is going to be read from the FORMATTED_DIR
    def find_missing_ranges(search_range, downloads_enum)
      dwnls = RangeWithGaps.new search_range.s1, search_range.s2
      dwnls.add downloads_enum.map { |d| d.date_range }
      
      missing = dwnls.gaps
      missing.to_a
    end

  
    # Return a formatted string of downloads
    def info()
      str = Rainbow("\n\t::: Download History for Account #{account_id} ::: \n").yellow
      downloads.each do |d|
        str = "\t" + str + d.to_s + "\n"
      end
      str = str + "\n" + show_missing_ranges + "\n"
    end

    def show_missing_ranges
      str = Rainbow("\n\t::: Missing Ranges for Account #{account_id} ::: \n").yellow
      missing = find_missing_ranges(DownloadRange.new(DateTime.now - 365, DateTime.now), downloads.to_enum )
      missing.each do |mr|
        str = str + "\n!!!\t\t[ #{mr.first.strftime( "%b %d, %Y")} .. #{mr.last.strftime( "%b %d, %Y")} ]"
      end
      str
    end

    def latest_download
      if (!self.download_dates.empty?)
        download_dates.sort.last
      end
    end

  end

end
