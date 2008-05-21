class ResourceType < ActiveRecord::Base
  
  require 'usage_record/utils'
  
  belongs_to              :usage_record
  validates_presence_of   :usage_record
    
  def self.get_all( usage_record, extension_props ) 
        
    unless extension_props.nil? || extension_props.empty?  
      objects = []    
      objects += Utils::get( ResourceType, extension_props[:resource_types], usage_record )     
      objects += Utils::get( ConsumableResourceType, extension_props[:consumable_resource_types], usage_record )
    end
  end
end

class ConsumableResourceType < ResourceType 
  validates_numericality_of :float_value, :only_integer => false
end
