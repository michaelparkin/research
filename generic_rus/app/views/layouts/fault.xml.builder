xml.instruct!
xml.Fault( :time => Time.now.iso8601 ) do
  xml.Message( flash[:notice] )
end