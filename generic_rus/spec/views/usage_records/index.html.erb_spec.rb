require File.dirname(__FILE__) + '/../../spec_helper'

describe "/usage_records/index.html.erb" do
  include UsageRecordsHelper
  
  before(:each) do
    usage_record_98 = mock_model(UsageRecord)
    usage_record_99 = mock_model(UsageRecord)

    assigns[:usage_records] = [usage_record_98, usage_record_99]
  end

  it "should render list of usage_records" do
    render "/usage_records/index.html.erb"
  end
end

