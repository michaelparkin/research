require File.dirname(__FILE__) + '/../spec_helper'
  
describe UsageRecordsController, 'handling GET /usage_records' do

  before(:each) do
    @usage_record = mock_model( UsageRecord )
    UsageRecord.stub!( :search_by_global_job_identity ).with( :search, :page, :sorted_by ).and_return( [@usage_records] )
    UsageRecord.stub!( :fetch ).with( :record_identity ).and_return( [@usage_record] )
    UsageRecord.stub!( :find ).with( :all )
  end
  
  def do_get
    get :index
  end
  
  it 'should be successful' do
    do_get
    response.should be_success
  end

  it 'should render index template' do
    do_get
    response.should render_template( 'index' )
  end
  
  it 'should find all usage_records' do
    UsageRecord.should_receive( :find ).with( :all ).and_return( [@usage_records] )
    do_get
  end
  
  #it "should assign the found usage_records for the view" do
  #  do_get
  #  assigns[:usage_records].should == [@usage_record]
  #end
end

# .xml
# .atom

