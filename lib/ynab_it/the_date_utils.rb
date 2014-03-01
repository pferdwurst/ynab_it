
    class DateTime
      # All arguments need to be DateTime objects
      def to_day
        self.strftime("%d").to_i
      end

      def to_year
        self.strftime("%Y").to_i
      end

    end


