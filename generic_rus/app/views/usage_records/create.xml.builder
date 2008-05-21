xml.instruct!

def build_attributes( record_number, message )
  attributes = { "recordNumber" => record_number }
  attributes["recordId"] = message[1] unless message[1].empty?
  return attributes
end

xml.ImportMessages( :time => Time.now.iso8601 ) do 

  if @messages.empty? && @errors.empty?
    xml.Message( "All usage records were imported successfully" )
  else 
    @messages.each do |record_number, message|
      xml.Message( message[0], build_attributes( record_number, message ) )
    end
    
    @errors.each do |record_number, message|
      xml.Error( message[0], build_attributes( record_number, message ) )
    end
  end
end

