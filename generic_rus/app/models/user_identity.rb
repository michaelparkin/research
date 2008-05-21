class UserIdentity < ActiveRecord::Base 
  
  has_one               :key_info, :as => :signable 
   
  belongs_to            :usage_record
  validates_presence_of :usage_record
  
  def self.get_all( usage_record, array )    
    unless array.nil? || array.empty?
      objects = []
      array.each do |entry|
        if entry[:local_user_identity] || entry[:global_user_name] || entry[:key_info]           
          entry[:usage_record] = usage_record
          key_info = entry.delete( :key_info )
          uid = UserIdentity.new( entry )
          uid.key_info = KeyInfo.new( key_info ) unless key_info.nil? || key_info.empty?      
          objects << uid
        end
      end
      return objects
    end
  end
end
  