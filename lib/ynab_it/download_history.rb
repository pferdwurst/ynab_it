module YnabIt
  class DownloadHistory

    # Holds a history of tx downloads
    attr_accessor :id, :download_path, :downloads, :latest_download, :download_dates, :account_id
    def initialize(account_id, dpath)
      self.download_path = dpath
      self.download_dates = []
      self.downloads = []
      self.account_id = account_id

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
              puts "Skipping directory #{start_date}: #{e}"
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

    def info()
      puts "=================== Download History for Account #{account_id}: ======== {\n"

      downloads.each  do |d|
        puts d
      end
      puts "}\n"

      puts " Missing Ranges for Account #{account_id}: {\n"
      missing = find_missing_ranges(DateTime.now - 365, DateTime.now )
      missing.each do |mr|
        puts "\t\t[ #{mr.first.strftime( "%b %d, %Y")} .. #{mr.last.strftime( "%b %d, %Y")} ]"
      end
      puts "\n================================================\n"
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
      start_date =date_range.first.strftime( "%b %d, %Y")
      end_date = date_range.last.strftime("%b %d, %Y")

      print "\t----+ #{fname}: #{start_date} - #{end_date} "
    end

  end
end
