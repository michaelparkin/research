require File.dirname(__FILE__) + '/../spec_helper'

module KeyInfoSpecHelper
  
  def valid_key_info_attributes 
    {
      :key_issuer_serial => 'test key issuer serial',
      :key_name => 'test_key_name',
      :key_ski => 'test_ski',
      :key_certificate => 'test_key_certificate',
      :signable => Factory.usage_record
    }
  end
  
end

describe KeyInfo do
     
  include KeyInfoSpecHelper
    
  before(:each) do
    @key_info = KeyInfo.new
  end
  
  it "should be valid with valid attributes" do
    @key_info.attributes = valid_key_info_attributes
    @key_info.should be_valid
  end
  
  it "should not be be valid without a usage record" do
    @key_info.attributes = valid_key_info_attributes.except( :signable )
    @key_info.should_not be_valid
  end
  
end

describe KeyInfo, ".get_key_info" do
  
  include KeyInfoSpecHelper
  
  before(:each) do
    @usage_record = Factory.usage_record
  end
    
  it "should change database when key info is assigned to usage record when attributes are valid" do
    lambda {
      @usage_record.key_info = KeyInfo.new( valid_key_info_attributes )
    }.should change( KeyInfo, :count ).by( 1 )
  end

  it "should assign key info to usage record if attributes are valid" do
    lambda {
      @usage_record.key_info = KeyInfo.new( valid_key_info_attributes )
    }.should change{ @usage_record.key_info }.from( nil )
  end
  
end

  

