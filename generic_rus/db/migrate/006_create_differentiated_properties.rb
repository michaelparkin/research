class CreateDifferentiatedProperties < ActiveRecord::Migration
  def self.up
    create_table  :differentiated_properties do |t|
      t.integer   :usage_record_id, :null => false  # cannot be null for all types
      t.string    :type                             # because we're using STI
      
      # note CPU duration is unique because it mixes fields from numeric and 'other' 
      # differentiated properties: it is composed of :time_duration, :description and :property_type

      t.string    :property_type                    # for disk type, memory type, swap type, time duration type, 
                                                    # time instant type and service level type
      
      # properties for numeric differentiated properties
      t.integer   :value
      t.string    :description
      t.string    :metric
      t.string    :storage_unit                     # from intervallicVolume attribute
      t.string    :phase_unit                       # from intervallicVolume attribute      
      t.float     :consumption_rate                 # odd property for processors
      
      # properties for 'other' differentiated properties
      t.string    :time_duration                    # check type : should be duration
      t.datetime  :time_instant
      t.string    :service_level   
      
    end
  end

  def self.down
    drop_table    :differentiated_properties
  end
end
