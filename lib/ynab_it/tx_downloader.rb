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
    include YnabIt::FileName

    attr_accessor :customer_id, :account_id
    def initialize(customer_id, account_id)
      super()
      self.customer_id = customer_id
      self.account_id = account_id
    end

    def fetch(client, start_date, end_date)
      range = DownloadRange.new(start_date, end_date)
      
      YnabIt.logger.info("Downloading transactions for account #{account_id} in the range #{range} ")
      
      history = DownloadHistory.new(account_id, formatted_base)
      download_ranges = history.find_missing_ranges2(range, history.downloads.to_enum)

      
      download_ranges.each do |r|
        start_date = r.first
        end_date = r.last
        YnabIt.logger.info("[acct: #{account_id}]::fetch:: Fetching transactions for dates #{start_date.strftime( "%b %d, %Y")} to #{end_date.strftime( "%b %d, %Y")}")

        old_stdout = $stdout.dup

        $stdout.reopen(raw_filename(account_id, YnabIt.to_datestr(start_date), YnabIt.to_datestr(end_date) ), "w")
        $stdout.sync = true
        $stderr.reopen("error.log")
        # get account transactions
        result = client.account_transactions(account_id, start_date, end_date)
        if result.nil?
          YnabIt.logger.error("[acct: #{account_id}]::fetch:: No transactions returned for dates #{start_date.strftime( "%b %d, %Y")} to #{end_date.strftime( "%b %d, %Y")}")
        else
          puts result
        end
        $stdout = old_stdout.dup
      end
    end

    def history
      DownloadHistory.new(account_id, formatted_base)
    end

  # # Fetch the transactions for the latest date range
  # def fetch_latest(the_client)
  #
  # history = DownloadHistory.new formatted_base
  # latest = history.latest_download
  # if latest.nil?
  #
  # # If the account has never been downloaded, go back 2 months
  # latest = DateTime.now - 2*31
  #
  # end
  #
  # diff = (DateTime.now - latest).to_i
  #
  # # If last download was more than a day ago...
  # if ( diff  > 1 )
  #
  # start_date=latest
  # end_date=DateTime.now
  #
  # YnabIt.logger.info("Getting transactions for dates #{start_date.strftime( "%b %d, %Y")} -- #{end_date.strftime( "%b %d, %Y")}")
  #
  # old_stdout = $stdout.dup
  #
  # $stdout.reopen(raw_filename(account_id, YnabIt.to_datestr(start_date), YnabIt.to_datestr(end_date)), "w")
  # $stdout.sync = true
  # $stderr.reopen("error.log")
  #
  # $stdout = old_stdout.dup
  # end
  # end
  end
end