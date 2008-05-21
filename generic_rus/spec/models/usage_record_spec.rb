require File.dirname(__FILE__) + '/../spec_helper'

describe UsageRecord do
    
  before( :each ) do
    @usage_record = UsageRecord.new
  end
    
  it "should be valid" do
    @usage_record.attributes = Factory.usage_record_attributes 
    @usage_record.should be_valid
  end
  
  it 'should have one error without status' do
    @usage_record.attributes = Factory.usage_record_attributes.except( :status )
    @usage_record.should have( 1 ).error_on( :status )
    @usage_record.errors.on( :status ).should == "can't be blank"
  end
  
  it 'should raise exception when saving if new record identity is a duplicate' do 
    # i.e. use the attributes of an already saved usage record
    @new_usage_record = UsageRecord.new( Factory.usage_record.attributes )
    lambda { @new_usage_record.save! }.should raise_error( 
      ActiveRecord::RecordInvalid, "Validation failed: Record identity has already been taken"
     )
  end
       
  it 'should allocate new record identity if empty' do
    @usage_record.attributes = Factory.usage_record_attributes.except( :record_identity )
    @usage_record.save!
    @usage_record.record_identity.should_not be_nil
  end
  
end

describe UsageRecord, ".fetch" do
    
  def fetch_usage_record( record_identity )
    @usage_record = UsageRecord.fetch( record_identity )
  end
  
  before( :each ) do
    @record_identity = Factory.usage_record.record_identity
  end
      
  it "should return a usage record and populate record identity" do
    fetch_usage_record( @record_identity )
    @usage_record.should_not be_nil
    @usage_record.record_identity.should_not be_nil
    @usage_record.record_identity.should eql( @record_identity ) 
  end
    
  it "should populate status" do
    fetch_usage_record( @record_identity )
    @usage_record.status.should_not be_nil
  end
  
  it "should be valid" do
    fetch_usage_record( @record_identity )
    @usage_record.should be_valid
  end
  
  it "should thow an exception when the record identity is non-existant" do   
    non_existent_record_identity = 'non-existent-record-identity' 
    lambda { UsageRecord.fetch( non_existent_record_identity ) }.should raise_error(
      ActiveRecord::RecordNotFound, 
      UsageRecord::NOT_FOUND + non_existent_record_identity
    )
  end

  it "should throw an exception when the record identity is empty" do
    lambda { UsageRecord.fetch( '' ) }.should raise_error(
      ActiveRecord::RecordNotFound, 
      UsageRecord::NO_ID_GIVEN
    )
  end
  
  it "should throw an exception when the record identity is nil" do
    lambda { UsageRecord.fetch( nil ) }.should raise_error(
      ActiveRecord::RecordNotFound, 
      UsageRecord::NO_ID_GIVEN
    )
  end
  
end

describe UsageRecord, ".search" do
  
  before( :each ) do
    @usage_record_one = Factory.usage_record
    @usage_record_two = Factory.usage_record
  end
    
  it "should return all usage records when search is empty" do
    UsageRecord.search( "", 1, "", "" ).length.should == 2
    UsageRecord.search( "", 1, "", nil ).length.should == 2
    UsageRecord.search( "", 1, nil, "" ).length.should == 2
    UsageRecord.search( "", 1, nil, nil ).length.should == 2
  end

  it "should return all usage records when search is nil" do
    UsageRecord.search( nil, 1, "", "" ).length.should == 2
    UsageRecord.search( nil, 1, "", nil ).length.should == 2
    UsageRecord.search( nil, 1, nil, "" ).length.should == 2
    UsageRecord.search( nil, 1, nil, nil ).length.should == 2
  end
  
  it "should return correct usage records when search is valid" #do
    #search = @usage_record_one.global_job_identity       
    #UsageRecord.search( search, 1, "", "" ).length.should == 1
    #UsageRecord.search( search, 1, "", nil ).length.should == 1
    #UsageRecord.search( search, 1, nil, "" ).length.should == 1   
    #UsageRecord.search( search, 1, nil, nil ).length.should == 1 
  #end

  it "should return no usage records when search is invalid"  #do
    #search = 'random_string'
    #UsageRecord.search( search, 1, "", "" ).length.should == 0
    #UsageRecord.search( search, 1, "", nil ).length.should == 0
    #UsageRecord.search( search, 1, nil, "" ).length.should == 0
    #UsageRecord.search( search, 1, nil, nil ).length.should == 0
  #end
  
  # How do I test the sort order? Do I need to test the sort order?
end

describe UsageRecord, ".destroy" do
      
  it "should throw an exception when we try to destroy a usage record" do
    lambda { UsageRecord.new.destroy }.should raise_error(
      ActiveRecord::ActiveRecordError,
      UsageRecord::CANNOT_DESTROY
    )
  end
  
end
