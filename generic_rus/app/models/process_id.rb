class ProcessId < ActiveRecord::Base
  
  belongs_to                :usage_record
  validates_presence_of     :usage_record
  
  validates_presence_of     :value
  validates_numericality_of :value, :only_integer => true, :greater_than_or_equal_to => 0
  
  def self.get_all( usage_record, array )    
    unless array.nil? || array.empty?
      objects = []
      array.each { |value| objects << ProcessId.new( { :value => value, :usage_record => usage_record } ) } 
      objects
    end
  end
end
