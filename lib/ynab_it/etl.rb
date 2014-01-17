require 'csv'
require 'fileutils'

=begin

Convert transactions outputed from aggcat to a
format that YNAB can import

=end

module YnabIt
  class ETL

    # The headers that YNAB expects on any CSV imported file
    @@CSV_HEADERS = ['Date', 'Payee', 'Category', 'Memo', 'Outflow',	'Inflow']

    @log = YnabIt.logger

    class << self
      # traverse the directory
      def process_dir(user, raw_directory, formatted_dir)

        @log.debug("Processing directory #{raw_directory}")

        if Dir.exist?(raw_directory)
          Dir.entries(raw_directory).each do |download_date|
            if (download_date =~ /^\./)
            next
            end
            
            date_dir = File.join(raw_directory, download_date)
            
            
            if ( File.directory?(date_dir) )
              @log.debug( "Directory <<#{download_date}>> +===============")

              Dir.entries(date_dir).each do |dwnld|

                unless ( ( dwnld =~ /.txs$/).nil? )
                  @log.debug( "\tProcessing raw file #{dwnld}")

                  begin
                    output_file = csv_filename(user, formatted_dir, dwnld)

                    @log.debug("Transforming to file #{output_file}")
                    
                    # Don't convert if the file's already been converted
                    unless File.exist?(output_file)
                      input = File.join(date_dir, dwnld)
                      input_json = File.read(input)

                      if (File.size(input) == 0)
                        @log.error( "Zero bytes in raw file #{input}")
                      next
                      end

                      txs = OpenStruct.new eval(input_json)

                      nested_txs = txs.result[:transaction_list][:banking_transaction]  || txs.result[:transaction_list][:credit_card_transaction]  || txs.result[:transaction_list][:loan_transaction ]
                      if nested_txs.nil?
                        @log.error( "Could not extract transactions for this account: ")
                      next
                      end

                      process_raw(nested_txs, output_file)
                      @log.info("Written to #{output_file}")
                    end
                  rescue   => e
                    @log.error("Could not parse the file #{dwnld}: #{e}")
                  end

                end
              end

            end
          end

        end
      end

      # Transform the downloaded transactions into
      # a CSV format that YNAB can read
      def process_raw( txs, csvfile)

        CSV.open(csvfile, "w") do |csv|

          csv <<  ['Date', 'Payee', 'Category', 'Memo', 'Outflow',  'Inflow']

          txs.each do |bk|

            compose_row = []
            # date
            if (bk.has_key?(:posted_date))
              txDate = DateTime.iso8601( bk[:posted_date] )
            else
              txDate = DateTime.iso8601( bk[:user_date] )
            end

            compose_row << txDate.strftime("%m/%d/%Y")

            # payee
            compose_row << bk[:payee_name]
            # category  (not sure how this works)
            # bk[:categorization]
            compose_row << ""
            # memo
            compose_row << bk[:memo]

            if bk[:amount].to_i > 0
              compose_row << nil
              compose_row <<  bk[:amount]
            else
            # If amount is negative, put it in the outflow column
            # (taking the absolute value)
              compose_row <<  bk[:amount].to_f.abs
              compose_row << nil
            end

            csv << compose_row
          end
        end

      end

      # generate the processed file name
      def csv_filename(user, formatted_dir, raw_filename)
        acct_id, start_date,end_date, ext = raw_filename.split(".")

        fldr = File.join(formatted_dir, user, acct_id, start_date)

        if ! Dir.exist?(fldr)
          FileUtils.mkpath(fldr)
        end

        fname = "#{acct_id}.#{start_date}.#{end_date}.csv"
        output = File.join(fldr, fname)
        return output
      end
    end

  # EOClass
  end
end

