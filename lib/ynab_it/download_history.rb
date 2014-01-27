module YnabIt
  class DownloadHistory

    # Holds a history of tx downloads
    attr_accessor :id, :download_path, :downloads, :latest_download, :download_dates, :account_id
    def initialize(account_id, dpath)
      self.download_path = dpath
      self.download_dates = []
      self.downloads = []
      self.account_id = account_id
      survey_downloads
    end

    def survey_downloads

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
    end

    # Return the ranges of dates for which there are no downloads
    # This is going to be read from the FORMATTED_DIR
    def find_missing_ranges(start_of_range, end_of_range)
      missing_ranges = []
      if downloads.empty?
        missing_ranges << Range.new(start_of_range, end_of_range)
      return missing_ranges
      end

      moving_start_of_range = start_of_range

      downloads.each do |d|
      # Break if we've moved past the end of range
        if d.date_range.first >= end_of_range
        break
        end

        if (moving_start_of_range < d.date_range.first)
          if d.date_range.first > end_of_range
            missing_ranges << Range.new(moving_start_of_range, end_of_range)
          moving_start_of_range = end_of_range
          else
            missing_ranges << Range.new(moving_start_of_range, d.date_range.first)
          moving_start_of_range = d.date_range.last
          end
        elsif start_of_range > d.date_range.first
        moving_start_of_range = d.date_range.last
        end
      end
      return missing_ranges
    end

    def find_missing_ranges2(start_range, end_range, dwnls_enum)
      missing = []

      if (start_range == end_range)
         return missing
      end

      # If there are no downloads then missing is the entire range
      begin
         dwnl = dwnls_enum.next
      rescue StopIteration
         missing << Range.new(start_range, end_range)
         return missing
      end

      start_day = start_range.strftime("%j")
      end_day = end_range.strftime("%j")
      year = start_range.strftime("%Y")

      # Check that the end day is not in the next year(s)
      if end_day <= start_day
        end_day =  "365"
      end
      # initialize loop
      i = start_day

      while i < end_day

        dwnl_start = dwnl.date_range.first.strftime("%j")
        begin
          if i < dwnl_start
            # missing [ i ... dwnl_start]
            missing << Range.new(DateTime.strptime(i + "-" + year, "%j-%Y"),  DateTime.strptime(dwnl_start + "-" + year, "%j-%Y"))
            i = dwnl.date_range.last.strftime("%j")
          elsif i = dwnl_start
            i = dwnl.date_range.last.strftime("%j")
          else
            YnabIt.logger.error("Finding missing downloads: loop failure..skipped past end of date segments")
          end
          dwnl = dwnls_enum.next
        rescue StopIteration
        # missing is the from the last match to the end_day
          missing << Range.new(DateTime.strptime(i + "-" + year, "%j-%Y"), DateTime.strptime(end_day + "-" + year, "%j-%Y"))
          i = end_day
        end
      end

      if year != end_range.strftime("%Y")
        next_year = (year.to_i + 1).to_s
        first_of_year = DateTime.strptime("001-" + next_year, "%j-%Y")
        missing = missing + find_missing_ranges2(first_of_year, end_range, dwnls_enum)
      end
      missing
    end

    def info()
      #print "\t::: Download History for Account #{account_id} ::: \n"
      print_downloads
      #print_missing_ranges
    end
    
    
    def print_downloads
     
      PP.pp(downloads, $>,  maxwidth = 50)
    end
  
   def print_missing_ranges
      #puts "\t::: Missing Ranges for Account #{account_id} ::: \n"
      #missing = find_missing_ranges2(DateTime.now - 365, DateTime.now, downloads.to_enum )
      #missing.each do |mr|
       # puts "\t\t[ #{mr.first.strftime( "%b %d, %Y")} .. #{mr.last.strftime( "%b %d, %Y")} ]\n"
      #end
    end

    def latest_download
      if (!self.download_dates.empty?)
        download_dates.sort.last
      end
    end

  end

  # Representing a single TX download

  class Download

    attr_accessor :id, :fname, :date_range, :account_id, :customer_id, :code, :count
    def initialize(filename)
      self.fname = filename
      self.account_id, start_date, end_date, ext = filename.split(".")
      d1 = YnabIt.to_date(start_date)
      d2 = YnabIt.to_date(end_date)
      self.date_range = Range.new(d1, d2)

    end

    def to_s
      "\t----+ #{fname}: #{date_range.first.strftime( "%b %d, %Y")} - #{date_range.last.strftime("%b %d, %Y")}"
    end

  end
end
