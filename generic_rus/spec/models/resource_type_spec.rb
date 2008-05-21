require File.dirname(__FILE__) + '/../spec_helper'

describe ResourceType do

  def valid_resource_type_attributes
    {
      :string_value => 'test value',
      :description => 'description of test value',
      :units => 'units of test value',
      :usage_record => Factory.usage_record
    }
  end
  
  def valid_consumable_resource_type_attributes
    {
      :float_value => 1.6543,
      :description => 'description of test value',
      :units => 'units of test value',
      :usage_record => Factory.usage_record
    }
  end
         
  def get_resource_type
    ResourceType.new
  end
  
  def get_consumable_resource_type
    ConsumableResourceType.new
  end
  
  it "resource type should be valid with valid attributes" do
    resource_type = get_resource_type
    resource_type.attributes = valid_resource_type_attributes
    resource_type.should be_valid
  end
  
  it "consumable resource type should be valid with valid attributes" do
    consumable_resource_type = get_resource_type
    consumable_resource_type.attributes = valid_consumable_resource_type_attributes
    consumable_resource_type.should be_valid
  end

  it "resource type should not be be valid without a usage record" do
    resource_type = get_resource_type
    resource_type.attributes = valid_resource_type_attributes.except( :usage_record )
    resource_type.should_not be_valid
  end
  
  it "consumable resource type should not be be valid without a usage record" do
    consumable_resource_type = get_consumable_resource_type
    consumable_resource_type.attributes = valid_resource_type_attributes.except( :usage_record )
    consumable_resource_type.should_not be_valid
  end
  
  it "consumable resource type should not be be valid without a value of type float" do
    consumable_resource_type = get_consumable_resource_type
    consumable_resource_type.attributes = valid_consumable_resource_type_attributes.with( :float_value => 'foo' )
    consumable_resource_type.should_not be_valid
  end
  
end

describe ResourceType, ".get_all" do
  
  def extension_properties 
    { 
      :resource_types => [ { :string_value => 'test value' }, { :string_value => 'test value' } ],
      :consumable_resource_types => [ { :float_value => '1.0123' }, { :float_value => '0.3560' } ]
     }
  end
  
  before(:each) do
    @usage_record = Factory.usage_record
  end
  
  it "should not touch database after assignment if resource types are empty" do
    resource_types = ResourceType.get_all( @usage_record, {} )

    lambda {
      @usage_record.resource_types = resource_types unless resource_types.nil?
    }.should_not change( @usage_record.resource_types, :count )
    
    lambda {
      @usage_record.resource_types = resource_types unless resource_types.nil?
    }.should_not change( ResourceType, :count )
  end

  it "should not touch database after assignment if resource types are nil" do
    lambda {
      resource_types = ResourceType.get_all( @usage_record, nil )
      @usage_record.resource_types = resource_types unless resource_types.nil?
    }.should_not change( @usage_record.resource_types, :count )
  end
    
  it "should not touch database after assignment if resource types are nil (alternate)" do
    lambda {
      resource_types = ResourceType.get_all( @usage_record, nil )
      @usage_record.resource_types = resource_types unless resource_types.nil?
    }.should_not change( ResourceType, :count )
  end
  
  it "should return four resource types" do      
    ResourceType.get_all( @usage_record, extension_properties ).length.should == 4
  end
      
  it "should not touch database without assigning to usage resource" do      
    lambda {
      ResourceType.get_all( @usage_record, extension_properties )
    }.should_not change( ResourceType, :count )
  end
  
  it "should not touch database without assigning to usage resource (alternate)" do      
    lambda {
      ResourceType.get_all( @usage_record, extension_properties )
    }.should_not change( @usage_record.resource_types, :count )
  end
    
  it "should increase the number of resource types in database" do
    lambda {      
      @usage_record.resource_types = ResourceType.get_all( @usage_record, extension_properties )    
    }.should change( ResourceType, :count ).by( 4 )
  end
  
  it "should increase the number of resource types in database (alternate)" do
    lambda {      
      @usage_record.resource_types = ResourceType.get_all( @usage_record, extension_properties )  
    }.should change( @usage_record.resource_types, :count ).by( 4 )
  end
        
  it "should increase the number of consumable resource types in database" do 
    lambda {
      @usage_record.resource_types = ResourceType.get_all( @usage_record, extension_properties )
    }.should change( ConsumableResourceType, :count ).by( 2 )
  end

  it "should increase the number of consumable resource types in database (alternate)" do     
    lambda {
      @usage_record.resource_types = ResourceType.get_all( @usage_record, extension_properties )
    }.should change( @usage_record.consumable_resource_types, :count ).by( 2 )
  end
  
end
