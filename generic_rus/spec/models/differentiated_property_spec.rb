require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../app/models/differentiated_property.rb'

module DifferentiatedPropertySpecHelper
  
  def network_valid_attributes
    {
      :value => 1000, 
      :description => 'network description',
      :metric => 'network metric',
      :storage_unit => 'network storage unit',
      :phase_unit => 'network phase unit'
    }
  end
  
  def disk_valid_attributes
    {
      :value => 1000,
      :description => 'disk description',
      :metric => 'disk metric',
      :property_type => 'disk type',
      :storage_unit => 'disk storage unit',
      :phase_unit => 'disk phase unit'
    }
  end

  def memory_valid_attributes
    {
      :value => 1000,
      :description => 'memory description',
      :metric => 'memory metric',
      :property_type => 'memory type',
      :storage_unit => 'memory storage unit',
      :phase_unit => 'memory phase unit'
    }
  end

  def swap_valid_attributes
    {
      :value => 1000,
      :description => 'swap description',
      :metric => 'swap metric',
      :property_type => 'swap type',
      :storage_unit => 'swap storage unit',
      :phase_unit => 'swap phase unit'
    }
  end

  def node_count_valid_attributes
    {
      :value => 1000,
      :description => 'node count description',
      :metric => 'node count metric',
      :storage_unit => 'node count storage unit',
      :phase_unit => 'node count phase unit'
    }
  end

  def processors_valid_attributes
    {
      :value => 1000,
      :description => 'processors description',
      :metric => 'processors metric',
      :storage_unit => 'processors storage unit',
      :phase_unit => 'processors phase unit',
      :consumption_rate => '0.1'
    }
  end
  
  def cpu_duration_valid_attributes
    {
     :time_duration =>  'PT48H00M00S',
     :property_type => 'user',
     :description => 'test cpu duration'
    }
  end

  def time_duration_valid_attributes
    {
      :time_duration => 'PT48H00M00S',
      :property_type => 'time duration type'      
    }
  end

  def time_instant_valid_attributes 
    {
      :time_duration => 'PT48H00M00S',
      :property_type => 'time duration type'
    }
  end

  def service_level_valid_attributes
    {
     :service_level => 'service level',
     :property_type => 'service level type'
    }  
  end

  def differentiated_props
    {
      :networks => [ network_valid_attributes ],
      :disks => [ disk_valid_attributes ],
      :memories => [ memory_valid_attributes ],
      :swaps => [ swap_valid_attributes ],
      :node_counts => [ node_count_valid_attributes ],
      :processors => [ processors_valid_attributes ],
      :cpu_durations => [ cpu_duration_valid_attributes ],
      :time_durations => [ time_duration_valid_attributes ],
      :time_instants => [ time_instant_valid_attributes ],
      :service_levels => [ service_level_valid_attributes ]
    }
  end
  
end

describe DifferentiatedProperty, ".get_all" do
  
  include DifferentiatedPropertySpecHelper
  
  before( :each ) do
    @usage_record = Factory.usage_record
  end
  
  it "should create correct amount of objects given a full hash of properties" do
    DifferentiatedProperty.get_all( @usage_record, differentiated_props ).length.should == 10
  end
  
  it "should create correct amount of objects given a hash but no network properties" do
    DifferentiatedProperty.get_all( @usage_record, differentiated_props.except( :networks ) ).
      length.should == 9
  end
  
  it "should create correct amount of objects given a hash but no network or disk properties" do    
    DifferentiatedProperty.get_all( @usage_record, differentiated_props.except( :processors ).
      except( :disks ) ).length.should == 8
  end
  
  it "should create correct amount of objects given a hash but no network, disk or memory properties" do    
    DifferentiatedProperty.get_all( @usage_record, differentiated_props.except( :processors ).
      except( :disks ).except( :memories ) ).length.should == 7
  end
  
  it "should not touch database after assignment if differentiated properties are empty" do
    differentiated_properties = DifferentiatedProperty.get_all( @usage_record, {} )  
    lambda {
      @usage_record.resource_types = differentiated_properties unless differentiated_properties.nil?
    }.should_not change( DifferentiatedProperty, :count )
  end

  it "should not touch database after assignment if differentiated properties are nil" do
    differentiated_properties = DifferentiatedProperty.get_all( @usage_record, nil )    
    lambda {
      @usage_record.resource_types = differentiated_properties unless differentiated_properties.nil?
    }.should_not change( DifferentiatedProperty, :count )
  end
  
  it "should change database when differentiated properties are assigned to usage record when attributes are valid" do    
    lambda {
      @usage_record.differentiated_properties = DifferentiatedProperty.get_all( @usage_record, differentiated_props )
    }.should change( DifferentiatedProperty, :count ).by( 10 )
  end
      
end

describe Network do
      
  include DifferentiatedPropertySpecHelper
  
  before( :each ) do
    @network_property = Network.new
    @valid_attributes = network_valid_attributes.with( :usage_record => Factory.usage_record )
  end
  
  it "should be valid with valid attributes" do
    @network_property.attributes = @valid_attributes
    @network_property.should be_valid
  end
  
  it "should be an instance of DifferentiatedProperty" do
    @network_property.is_a?( DifferentiatedProperty ).should be_true
  end
  
  it "should not be valid without usage record" do
    @network_property.attributes = @valid_attributes.except( :usage_record )
    @network_property.should_not be_valid
  end
  
  it "should be an instance of NumericDifferentiatedProperty" do
    @network_property.is_a?( NumericDifferentiatedProperty ).should be_true
  end
      
  it "should not be valid with a non-numeric value" do
    @network_property.attributes = @valid_attributes.with( :value => 'foo' )
    @network_property.should_not be_valid
  end
  
  it "should not be valid with a non-positive integer" do
    @network_property.attributes = @valid_attributes.with( :value => -1 )
    @network_property.should_not be_valid
  end

  it "should not be valid with a non-integer number" do
    @network_property.attributes = @valid_attributes.with( :value => 1.075 )
    @network_property.should_not be_valid
  end
  
  it "should be allocated a metric of total if none exists" do
    @network_property.attributes = @valid_attributes.except( :metric )
    @network_property.save!
    @network_property.metric.should == 'total'
  end
  
end

describe Disk do
  
  include DifferentiatedPropertySpecHelper
      
  before( :each ) do
    @disk_property = Disk.new
    @valid_attributes = disk_valid_attributes.with( :usage_record => Factory.usage_record )
  end
  
  it "should be valid with valid attributes" do
    @disk_property.attributes = @valid_attributes
    @disk_property.should be_valid
  end
  
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @disk_property.is_a?( DifferentiatedProperty ).should be_true
  end
  
  it "should be an instance of NumericDifferentiatedProperty" do
    # the network_property test the numericality of the value
    @disk_property.is_a?( NumericDifferentiatedProperty ).should be_true
  end
  
  it "should be allocated a metric of total if none exists" do
    @disk_property.attributes = @valid_attributes.except( :metric )
    @disk_property.save!
    @disk_property.metric.should == 'total'
  end

end

describe Memory do
    
  include DifferentiatedPropertySpecHelper
    
  before( :each ) do
    @memory_property = Memory.new
    @valid_attributes = memory_valid_attributes.with( :usage_record => Factory.usage_record )
  end
  
  it "should be valid with valid attributes" do
    @memory_property.attributes = @valid_attributes
    @memory_property.should be_valid
  end
  
  it "should not be valid without storage units" do
    @memory_property.attributes = @valid_attributes.except( :storage_unit )
    @memory_property.should_not be_valid
  end
    
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @memory_property.is_a?( DifferentiatedProperty ).should be_true
  end
  
  it "should be an instance of NumericDifferentiatedProperty" do
    # the network_property test the numericality of the value
    @memory_property.is_a?( NumericDifferentiatedProperty ).should be_true
  end
  
  it "should be allocated a metric of total if none exists" do
    @memory_property.attributes = @valid_attributes.except( :metric )
    @memory_property.save!
    @memory_property.metric.should == 'total'
  end
  
end

describe Swap do
  
  include DifferentiatedPropertySpecHelper
  
  before( :each ) do
    @swap_property = Swap.new
    @valid_attributes = swap_valid_attributes.with( :usage_record => Factory.usage_record )
  end
    
  it "should be valid with valid attributes" do
    @swap_property.attributes = @valid_attributes
    @swap_property.should be_valid
  end
    
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @swap_property.is_a?( DifferentiatedProperty ).should be_true
  end
  
  it "should be an instance of NumericDifferentiatedProperty" do
    # the network_property test the numericality of the value
    @swap_property.is_a?( NumericDifferentiatedProperty ).should be_true
  end
  
  it "should be allocated a metric of total if none exists" do
    @swap_property.attributes = @valid_attributes.except( :metric )
    @swap_property.save!
    @swap_property.metric.should == 'total'
  end
  
end

describe NodeCount do
    
  include DifferentiatedPropertySpecHelper
  
  before( :each ) do
    @node_count_property = NodeCount.new
    @valid_attributes = node_count_valid_attributes.with( :usage_record => Factory.usage_record )
  end
    
  it "should be valid with valid attributes" do
    @node_count_property.attributes = @valid_attributes
    @node_count_property.should be_valid
  end
    
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @node_count_property.is_a?( DifferentiatedProperty ).should be_true
  end
  
  it "should be an instance of NumericDifferentiatedProperty" do
    # the network_property test the numericality of the value
    @node_count_property.is_a?( NumericDifferentiatedProperty ).should be_true
  end
  
end

describe Processors do
    
  include DifferentiatedPropertySpecHelper
      
  before( :each ) do
    @processors_property = Processors.new
    @valid_attributes = processors_valid_attributes.with( :usage_record => Factory.usage_record )
  end
  
  it "should be valid with valid attributes" do
    @processors_property.attributes = @valid_attributes
    @processors_property.should be_valid
  end
    
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @processors_property.is_a?( DifferentiatedProperty ).should be_true
  end
    
  it "should be an instance of NumericDifferentiatedProperty" do
    # the network_property test the numericality of the value
    @processors_property.is_a?( NumericDifferentiatedProperty ).should be_true
  end
  
  it "should be valid with 0.67 for consumption rate" do
    @processors_property.attributes =  @valid_attributes.with( :consumption_rate => 0.67 )
    @processors_property.should be_valid
  end
  
  it "should be valid with 1 for consumption rate" do
    @processors_property.attributes =  @valid_attributes.with( :consumption_rate => 1 )
    @processors_property.should be_valid
  end

  it "should not be valid with a non-numeric consumption rate" do
    @processors_property.attributes = @valid_attributes.with( :consumption_rate => 'foo' )
    @processors_property.should_not be_valid
  end

  it "should not be valid with a non-positive float for consumption rate" do
    @processors_property.attributes =  @valid_attributes.with( :consumption_rate => -0.1 )
    @processors_property.should_not be_valid
  end

  it "should not be valid with a non-positive integer for consumption rate" do
    @processors_property.attributes =  @valid_attributes.with( :consumption_rate => -1 )
    @processors_property.should_not be_valid
  end

  it "should not be valid with a consumption rate greater than 1 (float)" #do
  #  @processors_property.attributes = @valid_attributes.with( :value => 1.075 )
  #  @processors_property.should_not be_valid
  #end

  it "should not be valid with a consumption rate greater than 1 (integer)" #do
    #@processors_property.attributes = @valid_attributes.with( :value => 2 )
    #@processors_property.should_not be_valid
  #end
  
end

describe CpuDuration do
  
  include DifferentiatedPropertySpecHelper
  
  before( :each ) do
    @cpu_duration = CpuDuration.new
    @valid_attributes = cpu_duration_valid_attributes.with( :usage_record => Factory.usage_record )
  end
    
  it 'should be invalid with anything other that user or system property type' do
    @cpu_duration.attributes = @valid_attributes.with( :property_type => 'invalid' )
    @cpu_duration.should_not be_valid
    
    #@cpu_duration.errors_on(:property_type).should == "cpu usage type 'invalid' is not valid"
    
    @cpu_duration.attributes = @valid_attributes.with( :property_type => 'user' )
    @cpu_duration.should be_valid
    
    @cpu_duration.attributes = @valid_attributes.with( :property_type => 'system' )
    @cpu_duration.should be_valid
  end
  
end

describe TimeDuration do
    
  include DifferentiatedPropertySpecHelper
      
  before( :each ) do
    @time_duration_property = TimeDuration.new
    @valid_attributes = time_duration_valid_attributes.with( :usage_record => Factory.usage_record )
  end
      
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @time_duration_property.is_a?( DifferentiatedProperty ).should be_true
  end
    
  it "should be an instance of OtherDifferentiatedProperty" do
    @time_duration_property.is_a?( OtherDifferentiatedProperty ).should be_true
  end
  
  it "should be valid with valid attributes" do
    @time_duration_property.attributes = @valid_attributes
    @time_duration_property.should be_valid
  end
  
  it "should not be valid without property type" do
      @time_duration_property.attributes = @valid_attributes.except( :property_type )
      @time_duration_property.should_not be_valid
  end
  
end

describe TimeInstant do
    
  include DifferentiatedPropertySpecHelper
      
  before( :each ) do
    @time_instant_property = TimeInstant.new
    @valid_attributes = time_instant_valid_attributes.with( :usage_record => Factory.usage_record )
  end
      
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @time_instant_property.is_a?( DifferentiatedProperty ).should be_true
  end
    
  it "should be an instance of OtherDifferentiatedProperty" do
     # the time_duration_property tests the requirement for a property_type
    @time_instant_property.is_a?( OtherDifferentiatedProperty ).should be_true
  end
  
  it "should be valid with valid attributes" do
    @time_instant_property.attributes = @valid_attributes
    @time_instant_property.should be_valid
  end
  
end

describe ServiceLevel do
    
  include DifferentiatedPropertySpecHelper
      
  before( :each ) do
    @service_level_property = ServiceLevel.new
    @valid_attributes = service_level_valid_attributes.with( :usage_record => Factory.usage_record )
  end
      
  it "should be an instance of DifferentiatedProperty" do
    # the network_property tests the requirement for a usage_record
    @service_level_property.is_a?( DifferentiatedProperty ).should be_true
  end
    
  it "should be an instance of OtherDifferentiatedProperty" do
     # the time_duration_property tests the requirement for a property_type
    @service_level_property.is_a?( OtherDifferentiatedProperty ).should be_true
  end
  
  it "should be valid with valid attributes" do
    @service_level_property.attributes = @valid_attributes
    @service_level_property.should be_valid
  end
  
end


