module YnabIt
  # Representing a single TX download
  class Download

    attr_accessor :id, :fname, :date_range, :account_id, :customer_id, :code, :count
    
    def initialize(filename)
      self.fname = filename
      self.account_id, start_date, end_date, ext = filename.split(".")
      d1 = YnabIt.to_date(start_date)
      d2 = YnabIt.to_date(end_date)
      self.date_range = DownloadRange.new(d1, d2)
    end

    def to_s
      "\t\t----+ #{date_range.first.strftime( "%b %d, %Y")} - #{date_range.last.strftime("%b %d, %Y")} (#{fname})"
    end

  end
end