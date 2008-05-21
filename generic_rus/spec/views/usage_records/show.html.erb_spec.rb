require File.dirname(__FILE__) + '/../../spec_helper'

describe "/usage_records/show.html.erb" do
  include UsageRecordsHelper
  
  before(:each) do
    @usage_record = mock_model(UsageRecord)

    assigns[:usage_record] = @usage_record
  end

  it "should render attributes in <p>" do
    render "/usage_records/show.html.erb"
  end
end

