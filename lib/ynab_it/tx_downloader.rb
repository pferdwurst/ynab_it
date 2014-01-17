=begin

Transactions are downloaded to a folder hierarchy:

downloads
|--raw
|   |--<customer_id>
|   |       +--accounts.<customer_id>
|   |       |--<download_date>
|   |       |         +--<account_id>.<download_date>.txs
|   |       |--<download_date>
|   |       |         +--<account_id>.<download_date>.txs
|
|--formatted
|     |--<customer_id>
|     |     |--<account_id>
|     |     |      |--<start_date>
|     |     |      |      +--<account_id>.<start_date>.<end_date>.csv
|     |     |      |      +--<account_id>.<start_date>.<end_date>.csv
|     |     |      |      +--<account_id>.<start_date>.<end_date>.csv
=end

module YnabIt
  class TxDownloader

    attr_accessor :customer_id, :account_id, :download_path
    def initialize(customer_id, account_id)
      super()
      self.customer_id = customer_id
      self.account_id = account_id
    end

  

    def today
      YnabIt.to_datestr(DateTime.now)
    end

    # Generate a filename that includes the start date of the download
    def raw_filename(account_id, start_date, end_date)
      dname = File.join(raw_dir, today)
      if !Dir.exist?(dname)
        Dir.mkdir(dname)
      end

      fname = File.join(dname, "#{account_id}.#{start_date}.#{end_date}.txs")

    end


    def fetch(client, start_date, end_date)
      
      # construct a date range between the present and the last download date
      # if no other range is given
      
      history = DownloadHistory.new(account_id, download_path)
      download_ranges = history.find_missing_ranges(start_date, end_date)

      download_ranges.each do |r|
        start_date = r.first
        end_date = r.last
        YnabIt.logger.info("Fetching transactions for dates #{start_date.strftime( "%b %d, %Y")} to #{end_date.strftime( "%b %d, %Y")}")

        old_stdout = $stdout.dup

        $stdout.reopen(raw_filename(account_id, YnabIt.to_datestr(start_date), YnabIt.to_datestr(end_date) ), "w")
        $stdout.sync = true
        $stderr.reopen("error.log")
        # get account transactions
        puts client.account_transactions(account_id, start_date, end_date)

        $stdout = old_stdout.dup
      end
    end

    def show_history
      history = DownloadHistory.new(account_id, self.download_path)
      history.info
    end

    # Fetch the transactions for the latest date range
    def fetch_latest(the_client)

      history = DownloadHistory.new self.download_path
      latest = history.latest_download
      if latest.nil?

        # If the account has never been downloaded, go back 2 months
        latest = DateTime.now - 2*31

      end

      diff = (DateTime.now - latest).to_i

      # If last download was more than a day ago...
      if ( diff  > 1 )

        start_date=latest
        end_date=DateTime.now

        YnabIt.logger.info("Getting transactions for dates #{start_date.strftime( "%b %d, %Y")} -- #{end_date.strftime( "%b %d, %Y")}")

        old_stdout = $stdout.dup

        $stdout.reopen(raw_filename(account_id, YnabIt.to_datestr(start_date), YnabIt.to_datestr(end_date)), "w")
        $stdout.sync = true
        $stderr.reopen("error.log")

      $stdout = old_stdout.dup
      end
    end
  end
end