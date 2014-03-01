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
    def find_missing_ranges2(search_range, dwnls_enum)
      missing = []
      YnabIt.logger.debug("Examinging range #{search_range}")
      if (search_range.empty?)
         return missing
      end

      # If there are no downloads then missing is the entire range
      begin
        dwnl = dwnls_enum.peek
      rescue StopIteration
         missing << search_range
         return missing
      end

      start_day = search_range.s1.yday #search_range.s1.strftime("%j")
      end_day = search_range.s2.yday
      year = search_range.s1.year

      # Check that the end day is not in the next year(s)
      if search_range.spans_years?
         end_day =  365
      end
      YnabIt.logger.debug("End day #{end_day}")
      # initialize loop
      i = start_day

      while i < end_day
        begin
          dwnl_start = dwnl.date_range.s1.yday
          dwnl_end = dwnl.date_range.s2.yday

           YnabIt.logger.debug("Looking at download #{dwnl}")

          if ( dwnl.date_range.s1.year != year)
            raise YearCrossoverException
          else
            dwnl = dwnls_enum.next
          end

          if i < dwnl_start
            # missing [ i ... dwnl_start]
            range_start = DateTime.strptime("#{i}-#{year}", "%j-%Y")
            range_end = DateTime.strptime("#{dwnl_start}-#{year}", "%j-%Y")

            unless range_start == range_end
               YnabIt.logger.debug "This is a missing range #{range_start} to #{range_end}"
              missing << Range.new(range_start, range_end)
            end
            i = dwnl.date_range.s2.yday
          elsif i = dwnl_start
            i = dwnl.date_range.s2.yday
          else
            YnabIt.logger.error("Finding missing downloads: loop failure..skipped past end of date segments")
          end

          dwnl = dwnls_enum.peek
        rescue StopIteration, YearCrossoverException
           YnabIt.logger.debug "Stop iterattion "
          # missing is the from the last match to the end_day
          range_start = DateTime.strptime("#{i}-#{year}", "%j-%Y")
          range_end =  DateTime.strptime("#{end_day}-#{year}", "%j-%Y")
          unless range_start == range_end
             YnabIt.logger.debug "This is a missing range #{range_start} to #{range_end}"

            missing << Range.new(range_start, range_end)
          end
        i = end_day
        end
         YnabIt.logger.debug "i = #{i}"
      end

       YnabIt.logger.debug " out of the loop"

      if search_range.spans_years?
        # redefine
        dwnl_start = dwnl.date_range.s1.yday
        dwnl_end = dwnl.date_range.s2.yday

        next_year = (year.to_i + 1).to_s
        # if last download ended before new year, use the first of the year
        if dwnl_end > dwnl_start
          next_start_of_range  = DateTime.strptime("001-" + next_year, "%j-%Y")
        else
        # if the last downloaded ended in the new year, use the end of the last download
          next_start_of_range  = DateTime.strptime("#{dwnl_end}-#{next_year}", "%j-%Y")
        end
         YnabIt.logger.debug "Move onto the next year"
        missing = missing + find_missing_ranges2(DownloadRange.new(next_start_of_range, search_range.s2), dwnls_enum)
      end

      missing
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
      missing = find_missing_ranges2(DownloadRange.new(DateTime.now - 365, DateTime.now), downloads.to_enum )
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
