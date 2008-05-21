require File.dirname(__FILE__) + '/../spec_helper'

require 'differentiated_property'
require 'resource_type'
require 'usage_record/urparser'

module UsageRecordParserSpecHelper
  
  # test cpu_duration_usage_type is either user or system
  # both can be present, but only once !!
  
  def record_with( xml_fragment, id = nil, include_status = true )
    if id && include_status
      open + record_id( id ) + status + xml_fragment + close  
    elsif id && !include_status
      open + record_id( id ) + xml_fragment + close
    else
      open + status + xml_fragment + close
    end
  end

  def xml_fragment( tag, value = nil, attributes = {} )
    tag = tag.camelize    

    if ( Object.const_get( tag ).new.is_a? NumericDifferentiatedProperty rescue false )
      "<#{tag} urwg:metric='total' urwg:storageUnit='MB'>" + ( value.nil? ? '1024' : value.to_s ) + "</#{tag}>"
    else
      xml = "<#{tag}"
      attributes.each { |k,v| xml += " urwg:#{k.to_s}='#{v.to_s}'" } unless attributes.empty?
      xml += ">#{value.to_s}</#{tag}>"
    end
  end

  private
  def open
    "<JobUsageRecord>"
  end

  def status
    "<Status>completed</Status>"
  end

  def record_id( id )
    "<RecordIdentity urwg:recordId='#{id}'/>"
  end

  def close
    "</JobUsageRecord>"
  end
  
end

describe UsageRecordParser, ' when parsing good records' do
  
  include UsageRecordParserSpecHelper
  
  before( :each ) do
    @good_record_1 = record_with( '', 'abcd' )
    @good_record_2 = record_with( '', 'efgh' )
  end
    
  it 'should parse a simple record with and identity with no messages' do
    messages, errors = UsageRecordParser.parse( @good_record_1 )    
    messages.should be_empty
    errors.should be_empty
  end
  
  it 'should add a simple record to database' do
    lambda {
      UsageRecordParser.parse( @good_record_1 )
    }.should change( UsageRecord, :count ).by( 1 )
  end
    
  it 'should add two records with different record identities to the database' do
    two_usage_records = "<JobUsageRecords>" + @good_record_1 + @good_record_2 + "</JobUsageRecords>"
    lambda {
      UsageRecordParser.parse( two_usage_records )
    }.should change( UsageRecord, :count ).by( 2 )
  end
    
end

describe UsageRecordParser, ' when parsing records with missing mandartory information' do
  
  include UsageRecordParserSpecHelper
  
  before( :each ) do
    @bad_record = record_with( '', 'abcd', false )
    @good_record = record_with( '', 'abcd' )
  end
    
  it 'should return one error when parsing a record without a status' do
    messages, errors = UsageRecordParser.parse( @bad_record )
    messages.should be_empty
    errors.length.should == 1           
  end
  
  it 'should return the correct message when parsing a record without a status' do
    messages, errors = UsageRecordParser.parse( @bad_record )
    messages.should be_empty
    errors[1][0].should == "Validation failed: Status can't be blank"
  end
        
  it 'should not touch the database when parsing a record without a status' do
    lambda {
      UsageRecordParser.parse( @bad_record )
    }.should_not change( UsageRecord, :count )
  end
  
  it 'should return two errors when parsing two records without a status' do
    two_usage_records = "<JobUsageRecords>" + @bad_record + @bad_record + "</JobUsageRecords>"
    messages, errors = UsageRecordParser.parse( two_usage_records )
    messages.should be_empty
    errors.length.should == 2
  end
  
  it 'should add only one of two records with the same record identity to the database' do
    two_usage_records = "<JobUsageRecords>" + @good_record + @good_record + "</JobUsageRecords>"
    lambda {
      UsageRecordParser.parse( two_usage_records )
    }.should change( UsageRecord, :count ).by( 1 )
  end
  
  it 'should give correct message when trying to add two records with the same record identity to the database' do
    two_usage_records = "<JobUsageRecords>" + @good_record + @good_record + "</JobUsageRecords>"
    messages,errors = UsageRecordParser.parse( two_usage_records )
    messages[1].should be_nil
    errors[2][0].should == "Validation failed: Record identity has already been taken"
  end
    
  it 'should assign a new record identity when the identity is empty' do
    messages, errors = UsageRecordParser.parse( record_with( '', '' ) )
    messages[1].should_not be_nil
    messages[1][0].should include( 'The record was assigned the identity ' )
  end
  
  it 'should assign a new record identity when the identity is nil' do
    messages, errors = UsageRecordParser.parse( record_with( '', nil ) )
    messages[1].should_not be_nil
    messages[1][0].should include( 'The record was assigned the identity ' )
  end

end

describe UsageRecordParser, ' when parsing simple common proprerties' do
  
  include UsageRecordParserSpecHelper
  
  before( :each ) do
    @record_identity = '1234'
    @description = 'test description'
  end
  
  def test_common_property( tag, value = nil, attributes = {} )    
    value = 'test ' +  tag.humanize.downcase if value.nil?  
    attributes[:description] = @description
    UsageRecordParser.parse( record_with( xml_fragment( tag, value, attributes ), @record_identity ) )
    ur = UsageRecord.fetch("#{@record_identity}")
      
    stored_value = ur.instance_eval( tag )
    
    if stored_value.is_a?( Time )
      ur.instance_eval( tag ).should == Time.parse( value )
    else
      stored_value.is_a?( value.class ).should be_true
      ur.instance_eval( tag ).should == value 
    end
    
    ur.instance_eval( tag + '_description' ).should == "#{@description}"
  end
        
  it 'should add a job name to the usage record' do
    test_common_property( 'job_name' )
  end
  
  it 'should add a charge to the usage record' do
    test_common_property( 'charge', 1.01, :unit => 'test unit', :formula => 'test formula' )
  end
  
  it 'should add a wall duration to the usage record' do
    test_common_property( 'wall_duration' )
  end
    
  it 'should add a start time to the usage record' do
    test_common_property( 'start_time', '2008-01-01T10:01:01Z' )
  end

  it 'should add an end time to the usage record' do
    test_common_property( 'end_time', '2008-01-02T10:01:01Z' )
  end

  it 'should add a machine name to the usage record' do
    test_common_property( 'machine_name' )
  end

  it 'should add a host to the usage record' do
    test_common_property( 'host', nil, :primary => true )
  end

  it 'should add a submit host to the usage record' do
    test_common_property( 'submit_host' )
  end

  it 'should add a queue to the usage record' do
    test_common_property( 'queue' )
  end

  it 'should add a project name to the usage record' do
    test_common_property( 'project_name' )
  end
  
end

describe UsageRecordParser, ' when parsing the job identity' do
  
  include UsageRecordParserSpecHelper
    
  it 'should add a global job identity (and not a local job identity) to the usage record' 
  
  it 'should not add a local job identity (and not a global job identity) to the usage record'

  it 'should not add a usage record to the database if there is no local or global job identity'
  
  it 'should add a process id object to the database' do
    xml = xml_fragment( 'job_identity', xml_fragment( 'process_id', 1000 ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should change( ProcessId, :count ).by( 1 )
  end
  
  it 'should not add a process id object to the database (no value)' do
    xml = xml_fragment( 'job_identity', xml_fragment( 'process_id' ) )    
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should_not change( ProcessId, :count )
  end
  
end

describe UsageRecordParser, ' when parsing more complicated common propertes' do
  
  include UsageRecordParserSpecHelper
    
  def get_key_info( tag, value = nil )
    xml  = "<ds:KeyInfo><X509Data>"
    xml += xml_fragment( tag, value ) unless tag.nil?
    xml += "</X509Data></ds:KeyInfo>" 
  end
  
  it 'should add a key info object to the database (X509SubjectName)' do    
    xml = xml_fragment( 'record_identity', get_key_info( 'X509SubjectName', 'subject name' ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should change( KeyInfo, :count ).by( 1 )
  end
  
  it 'should add a key info object to the database (X509IssuerSerial)' do    
    xml = xml_fragment( 'record_identity', get_key_info( 'X509IssuerSerial', 'issuer serial' ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should change( KeyInfo, :count ).by( 1 )
  end
      
  it 'should add a key info object to the database (X509Ski)' do    
    xml = xml_fragment( 'record_identity', get_key_info( 'X509Ski', 'ski' ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should change( KeyInfo, :count ).by( 1 )    
  end
  
  it 'should add a key info object to the database (X509Certificate)' do    
    xml = xml_fragment( 'record_identity', get_key_info( 'X509Certificate', 'certificate' ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should change( KeyInfo, :count ).by( 1 )
  end
  
  it 'should not add a key info object to the database (no data value or subject name)' do
    xml = xml_fragment( 'record_identity', get_key_info( nil ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should_not change( KeyInfo, :count )
  end
      
  it 'should add a user identity to the database' do
    xml = xml_fragment( 'user_identity', xml_fragment('local_user_id', '1234' ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should change( UserIdentity, :count ).by( 1 )
  end
  
  it 'should add a user identity to the database' do
    xml = xml_fragment( 'user_identity', xml_fragment('global_user_name', 'test name' ) )    
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should change( UserIdentity, :count ).by( 1 )
  end

  it 'should not add a user identity to the database (no local user id value)' do
    xml = xml_fragment( 'user_identity', xml_fragment( 'local_user_id' ) )
    lambda{
      UsageRecordParser.parse( record_with( xml ) )
    }.should_not change( UserIdentity, :count )
  end
  
end

describe UsageRecordParser, ' when parsing differentiated properties' do
  
  include UsageRecordParserSpecHelper
        
  it 'should add a network object to the database' do      
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'network' ) ) )
    }.should change( Network, :count ).by( 1 )
  end
  
  it 'should not add a network object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'network', '' ) ) )
    }.should_not change( Network, :count )
  end
      
  it 'should add a disk object to the database' do    
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'disk' ) ) )
    }.should change( Disk, :count ).by( 1 )
  end
  
  it 'should not add a disk object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'disk', '' ) ) )
    }.should_not change( Disk, :count )
  end
      
  it 'should add a memory object to the database' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'memory' ) ) )
    }.should change( Memory, :count ).by( 1 )
  end
  
  it 'should not add a memory object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'memory', '' ) ) )
    }.should_not change( Memory, :count )
  end
    
  it 'should add a swap object to the database' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'swap' ) ) )
    }.should change( Swap, :count ).by( 1 )
  end
  
  it 'should not add a swap object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'swap', '' ) ) )
    }.should_not change( Swap, :count )
  end
  
  it 'should add a node count object to the database' do
    # check this - description ?
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'node_count' ) ) )
    }.should change( NodeCount, :count ).by( 1 )
  end
  
  it 'should not add a node count object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'node_count', '' ) ) )
    }.should_not change( NodeCount, :count )
  end
    
  it 'should add a processors object to the database' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'processors', 32, :description => 'total', :metric => 'total' ) ) )
    }.should change( Processors, :count ).by( 1 )
  end
  
  it 'should not add a processors object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'processors', '', :description => 'total', :metric => 'total' ) ) )
    }.should_not change( Processors, :count )
  end
    
  it 'should add a cpu duration object to the database' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'cpu_duration', 'PT00H00M01S', :description => 'total', 'usageType' => 'user' ) ) )
    }.should change( CpuDuration, :count ).by( 1 )
  end
  
  it 'should not add a cpu duration object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'cpu_duration', '', :description => 'total', 'usageType' => 'user' ) ) )
    }.should_not change( CpuDuration, :count )
  end
    
  it 'should add a time duration object to the database' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'time_duration', 'PT48H00M00S' , :type => 'connect' ) ) )
    }.should change( TimeDuration, :count ).by( 1 )
  end
  
  it 'should not add a time duration object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'time_duration', '', :type => 'connect' ) ) )
    }.should_not change( TimeDuration, :count )
  end
  
  it 'should not add a time duration object to the database (no type)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'time_duration', 'PT48H00M00S' ) ) )
    }.should_not change( TimeDuration, :count )
  end
    
  it 'should add a time instant object to the database' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'time_instant', '2006-05-30T16:01:51', :type => 'submit' ) ) )
    }.should change( TimeInstant, :count ).by( 1 )
  end
  
  it 'should not add a time instant object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'time_instant', '', :type => 'submit' ) ) )
    }.should_not change( TimeInstant, :count )
  end
    
  it 'should not add a time instant object to the database (no type)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'time_instant', '2006-05-30T16:01:51' ) ) )
    }.should_not change( TimeInstant, :count )
  end

  it 'should add a service level object to the database' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'service_level', 'token', :type => 'defined policy' ) ) )
    }.should change( ServiceLevel, :count ).by( 1 )
  end

  it 'should not add a service level object to the database (no value)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'service_level', '', :type => 'defined policy' ) ) ) 
    }.should_not change( ServiceLevel, :count )
  end
  
  it 'should not add a service level object to the database (no type)' do
    lambda{
      UsageRecordParser.parse( record_with( xml_fragment( 'service_level', 'token' ) ) )
    }.should_not change( ServiceLevel, :count )
  end
    
end

describe UsageRecordParser, " when parsing resource types" do
  
  include UsageRecordParserSpecHelper
  
  def fragment( tag, value = 'test ' + tag.humanize.downcase )
    "<#{tag.camelize}>#{value}</#{tag.camelize}>"
  end
  
  it "should add a resource type to the database" do
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'resource_type' ) ) )
    }.should change( ResourceType, :count ).by( 1 )
  end
  
  it "should add a resource type to the database (alternative 1)" do
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'resource' ) ) )
    }.should change( ResourceType, :count ).by( 1 )
  end
  
  it "should add a resource type to the database (alternative 2)" do  
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'resources' ) ) )
    }.should change( ResourceType, :count ).by( 1 )
  end
  
  it "should not add a resource type to the database (no value)" do
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'resource_type', '' ) ) )
    }.should_not change( ResourceType, :count )
  end

  it "should add a consumable resource type to the database" do
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'consumable_resource_type', 1.023 ) ) )
    }.should change( ConsumableResourceType, :count ).by( 1 )
  end
  
  it "should add a consumable resource type to the database (alternate 1)" do
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'consumable_resource', 1.023 ) ) )
    }.should change( ConsumableResourceType, :count ).by( 1 )
  end
  
  it "should add a consumable resource type to the database (alternate 2)" do
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'consumable_resources', 1.023 ) ) )
    }.should change( ConsumableResourceType, :count ).by( 1 )
  end
  
  it "should not add a consumable resource type to the database (no value)" do
    lambda{
      UsageRecordParser.parse( record_with( fragment( 'consumable_resource_type', '' ) ) )
    }.should_not change( ConsumableResourceType, :count )
  end
  
end