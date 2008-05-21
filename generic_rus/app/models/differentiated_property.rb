class DifferentiatedProperty < ActiveRecord::Base
  
  require 'usage_record/utils'
  
  belongs_to              :usage_record
  validates_presence_of   :usage_record
    
  def self.get_all( usage_record, differentiated_props )
   
    unless differentiated_props.nil? || differentiated_props.empty?
      objects = []
      objects += Utils::get( Network, differentiated_props[:networks], usage_record )
      objects += Utils::get( Disk, differentiated_props[:disks], usage_record )
      objects += Utils::get( Memory, differentiated_props[:memories], usage_record )
      objects += Utils::get( Swap, differentiated_props[:swaps], usage_record )
      objects += Utils::get( NodeCount, differentiated_props[:node_counts], usage_record )      
      objects += Utils::get( Processors, differentiated_props[:processors], usage_record )  
      objects += Utils::get( CpuDuration, differentiated_props[:cpu_durations], usage_record )  
      objects += Utils::get( TimeDuration, differentiated_props[:time_durations], usage_record )  
      objects += Utils::get( TimeInstant, differentiated_props[:time_instants], usage_record )  
      objects += Utils::get( ServiceLevel, differentiated_props[:service_levels], usage_record )
    end
  end
  
  protected
  def assign_default_metric
    self.metric = 'total' if self.metric.blank?
  end
  
end

class NumericDifferentiatedProperty < DifferentiatedProperty    
  validates_numericality_of :value, :only_integer => true, :greater_than_or_equal_to => 0
end

class Network < NumericDifferentiatedProperty
  before_create :assign_default_metric
end

class Disk < NumericDifferentiatedProperty
  before_create :assign_default_metric
end

class Memory < NumericDifferentiatedProperty
  validates_presence_of :storage_unit
  before_create :assign_default_metric
end

class Swap < NumericDifferentiatedProperty
  before_create :assign_default_metric
end

class NodeCount < NumericDifferentiatedProperty
end

class Processors < NumericDifferentiatedProperty
  validates_numericality_of :consumption_rate, :only_integer => false, :allow_nil => true, :greater_than_or_equal_to => 0 
end

class OtherDifferentiatedProperty < DifferentiatedProperty 
  validates_presence_of :property_type
end

class TimeDuration < OtherDifferentiatedProperty
end

class TimeInstant < OtherDifferentiatedProperty
end

class ServiceLevel < OtherDifferentiatedProperty
end

class CpuDuration < OtherDifferentiatedProperty
  #validates_inclusion_of :property_type, :in => %w( user system ), :message => "cpu usage type '%s' is not valid"
end
