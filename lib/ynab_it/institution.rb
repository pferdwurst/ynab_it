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
       "\n\t\tname:           #{name}
        \tinstitution_id: #{id}
        \turl:            #{home_url}
       "
    end
    
    def show(formatter)
      "\t\tname:\t" + formatter.wrap("#{name}").black + "\n" +
      "\t\tinstitution_id:\t" + formatter.wrap("#{id}").black + "\n" +
      "\t\tURL:\t" + formatter.wrap("#{home_url}").black + "\n"
      
    end

  end
end
