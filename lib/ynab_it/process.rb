module YnabIt
  class Process
    class << self
    

      def get customer, accounts = {}
        if accounts.empty?
          accounts = customer.accounts
        end
        accounts.values.each  do |a|
          dwnldr = a.downloader
          # dwnldr.show_history

          dwnldr.fetch(customer.client, DateTime.strptime("20130901", "%Y%m%d"), DateTime.now )
        end
      end

      def transform customer
        ETL.process_dir(customer.customer_id, customer.raw_dir, customer.formatted_dir)
      end

    end
  end
end