module YnabIt
  class Institution  
    # Defines a bank/institution account struct

    attr_accessor :id, :name, :home_url
    
    class << self
      def load(hsh)
        if ( !hsh.nil? )
           i = Institution.new
           i.id = hsh[:institution_id]
           i.name = hsh[:institution_name]
           i.home_url = hsh[:home_url]
        
           i
        end
      end
    end

    def to_s()
       "
                  name:           #{name},
                  institution_id: #{id},
                  url:            #{home_url}
         "
    end

  end
end
