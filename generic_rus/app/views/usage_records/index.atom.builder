base_url = request.protocol + request.host_with_port + request.request_uri

# this needs changing as atom feed builder isn't great
atom_feed( :url =>  base_url ) do |feed|
  
  feed.title( 'Usage Records' )
  feed.updated( @usage_records.first ? @usage_records.first.created_at : Time.now.utc )
  
  for record in @usage_records
    feed.entry( record, :url => base_url + "/" + record.record_identity ) do |entry|
      entry.title( record.record_identity )      
      entry.content( :type => Mime::USAGE_RECORD_DOC ) {
        #render_partial( 'usage_record', :locals => { :request => request, :xml_instance => xml } )
        render_partial( 'usage_record', :locals => { :xml => xml } )
      }
    end
  end
end