module YnabIt
  class Process
    class << self
      def get customer
        customer.accounts.each  do |a|
          puts "account_id = #{a.account_id}"
          dwnldr = a.downloader
          dwnldr.show_history

          dwnldr.fetch(customer.client, DateTime.strptime("20130901", "%Y%m%d"), DateTime.now )
        end
      end

      def transform customer
        
        ETL.process_dir(customer.customer_id, customer.raw_dir, customer.formatted_dir)

      end

      def show
        customer.accounts.each  do |a|
          puts "account_id = #{a.account_id}"
          dwnldr = a.downloader
          dwnldr.show_history
        end
      end
    end
  end
end