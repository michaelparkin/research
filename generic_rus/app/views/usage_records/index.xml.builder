xml.instruct!
xml.JobUsageRecords do
  @usage_records.each do |record|
    render_partial( 'usage_record', :locals => { :xml => xml } )
  end
end
