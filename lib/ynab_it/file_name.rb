require 'fileutils'

module YnabIt
  module FileName

    #:raw_base, :formatted_base, :account_id, :start_date, :end_date
    @@FILE_DATE_FORMAT = "%Y%m%d"
    @@DISPLAY_DATE_FORMAT = "%b %d, %Y"
    def raw_base=(raw_dir)
      @@raw_base = raw_dir
    end

    def raw_base
      @@raw_base
    end

    def formatted_base=(f_dir)
      @@formatted_base = f_dir
    end

    def formatted_base
      @@formatted_base
    end

    def today
      YnabIt.to_datestr(DateTime.now)
    end

    # Generate a filename that includes the start date of the download
    def raw_filename(account_id, start_date, end_date)
      dname = File.join(@@raw_base, today)
      if !Dir.exist?(dname)
        Dir.mkdir(dname)
      end

      fname = File.join(dname, "#{account_id}.#{start_date}.#{end_date}.txs")
    end

    def extract_dates(fname)
      # A file should look like: <account_id>.<start>.<end>.<txs|csv>
      #   e.g. 400010252106.20130901.20131012.txs
      account_id, beginning, ending, ext = fname.split(".", 4)

      start_date = DateTime.strptime(beginning, @@FILE_DATE_FORMAT)
      end_date = DateTime.strptime(ending, @@FILE_DATE_FORMAT)

      return Range.new(start_date, end_date)
    end

    def display_dates(fname)
      dr = extract_dates(fname)
      "[ #{dr.first.strftime(@@DISPLAY_DATE_FORMAT)} - #{dr.last.strftime(@@DISPLAY_DATE_FORMAT)}]"
    end
  end
end