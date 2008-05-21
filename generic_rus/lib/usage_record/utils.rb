class Utils
      
  def self.get( new_class, from_array, usage_record )
    objects = []
    if from_array && !from_array.empty?
      from_array.each do |entry| 
        entry[:usage_record] = usage_record
        objects << new_class.new( entry ) 
      end
    end
    return objects
  end
end