xml.instruct!

def build_attributes( record_number, message )
  attributes = {}
  attributes[:record_number] = record_number
  attributes[:record_id] = message[1] unless message[1].empty?
end

xml.ImportMessages do 

  if @messages.empty? && @errors.empty?
    xml.Message( "All usage records were imported successfully" )
  else 
    @messages.each do |record_number, message|
      xml.Message( messages[0], build_attributes( record_number, message ) )
    end
    
    @errors.each do |record_number, message|
      xml.Error( message[0], build_attributes( record_number, message ) )
    end
  end
end

