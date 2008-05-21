xml.comment! record_url = request.protocol.concat( request.host_with_port ).concat( request.request_uri )

namespaces = {
  "xmlns"     => "http://schema.ogf.org/urf/2003/09/urf",
  "xmlns:urwg"=> "http://schema.ogf.org/urf/2003/09/urf",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xmlns:ds"  => "http://www.w3.org/2000/09/xmldsig#", 
  "xsi:schemaLocation" => "http://www.gridforum.org/2003/ur-wg/urwg-schema.09.02.xsd"
}

def add_key_info( xml, key_info )
  xml.ds :KeyInfo do
    xml.X509Data do
      xml.X509SubjectName( key_info.key_name ) if key_info.key_name
      xml.X509IssuerSerial( key_info.key_issuer_serial ) if key_info.key_issuer_serial 
      xml.X509SKI( key_info.key_ski ) if key_info.key_ski
      xml.X509Certificate( key_info.key_certificate ) if key_info.key_certificate
    end
  end
end

xml.UsageRecord( namespaces ) {
  
  attributes = {}
  attributes["recordIdentity"] = @usage_record[:record_identity]
  attributes["createTime"] = @usage_record[:record_create_time].iso8601 if @usage_record[:record_create_time]

  xml.RecordIdentity( attributes ) {

      if @usage_record.key_info
        xml.comment! 	'identifies the entity that created a particular usage record'
        add_key_info( xml, @usage_record.key_info ) 
      end
      
  }
  
  # is this optional?
  xml.JobIdentity {
        
    if local_job_id = @usage_record[:local_job_identity]
      xml.LocalJobId( local_job_id ) 
    end
    
    if global_job_id = @usage_record[:global_job_identity]
      xml.GlobalJobId( global_job_id ) 
    end
    
    @usage_record.process_ids.each do |id|
      xml.ProcessId( id[:value] )
    end 
     
  }
  
  @usage_record.user_identities.each do |id|
  
    xml.UserIdentity {
 
      if local_user_id = id[:local_user_identity] 
        xml.LocalUserId( local_user_id )
      end
   
      if global_user_name = id[:global_user_name]
        xml.GlobalUserName( global_user_name )
      end

      if id.key_info
        xml.comment! 'the contents of this element represent the global identity for the user associated with this usage'
        add_key_info( xml, id.key_info) 
      end
    
    }
  
  end
  
  if job_name = @usage_record[:job_name]
    attributes = {}
    attributes["description"] = @usage_record[:job_name_description] if @usage_record[:job_name_description]
    xml.JobName( job_name, attributes )
  end
  
  if charge = @usage_record[:charge]
    attributes = {}
    attributes["description"] = @usage_record[:charge_description] if  @usage_record[:charge_description]
    attributes["chargeUnit"] = @usage_record[:charge_unit] if @usage_record[:charge_unit]
    attributes["charge_forumla"] = @usage_record[:charge_formula] if @usage_record[:charge_formula]
    xml.Charge( charge, attributes )
  end
  
  if status = @usage_record[:status]
    attributes = {}
    attributes["description"] = @usage_record[:status_description] if @usage_record[:status_description]
    xml.Status( status, attributes )
  end

  if wall_duration = @usage_record[:wall_duration]  
    attributes = {}
    attributes["description"] = @usage_record[:wall_duration_description] if @usage_record[:wall_duration_description] 
    xml.WallDuration( wall_duration, attributes )
  end
  
  if cpu_duration = @usage_record[:cpu_duration]
    attributes = {}
    attributes["description"] = @usage_record[:cpu_duration_description] if  @usage_record[:cpu_duration_description]
    xml.CpuDuration( cpu_duration, attributes )
  end

  if end_time = @usage_record[:end_time]
    attributes = {}
    attributes["description"] = @usage_record[:end_time_description] if @usage_record[:end_time_description]
    xml.EndTime( end_time.iso8601, attributes )
  end
  
  if start_time = @usage_record[:start_time]
    attributes = {} 
    attributes["description"] = @usage_record[:start_time_description] if @usage_record[:start_time_description]
    xml.StartTime( start_time.iso8601, attributes )
  end

  if machine_name = @usage_record[:machine_name]
    attributes = {}
    attributes["description"] = @usage_record[:machine_name_description] if @usage_record[:machine_name_description]
    xml.MachineName( machine_name, attributes )
  end

  if host = @usage_record[:host]
    attributes = {}
    attributes["description"] = @usage_record[:host_description] if @usage_record[:host_description]
    attributes["primary"] = @usage_record[:primary_host] if @usage_record[:primary_host]
    xml.Host( host, attributes )
  end

  if submit_host =  @usage_record[:submit_host]
    attributes = {} 
    attributes["description"] = @usage_record[:submit_host_description] if @usage_record[:submit_host_description]
    xml.SubmitHost( submit_host, attributes )
  end

  if queue =  @usage_record[:queue]
    attributes = {}
    attributes["description"] = @usage_record[:queue_description] if @usage_record[:queue_description]
    xml.Queue( queue, attributes )
  end

  if project_name =  @usage_record[:project_name]
    attributes = {}
    attributes["description"] = @usage_record[:project_name_description] if @usage_record[:project_name_description]
    xml.ProjectName( project_name, attributes )
  end
  
  @usage_record.differentiated_properties.each do |property|
    
    attributes = {}
    attributes["type"] = property[:property_type] if property[:property_type]
    attributes["description"] = property[:description] if property[:description]
    attributes["metric"] = property[:metric] if property[:metric]
    attributes["storageUnit"] = property[:storage_unit] if property[:storage_unit]
    attributes["phaseUnit"] = property[:phase_unit] if property[:phase_unit]
    attributes["consumptionRate"] = property[:consumption_rate] if property[:consumption_rate]
        
    if property.is_a? TimeInstant
      value = property.time_instant.iso8601
    elsif property.is_a? TimeDuration
      value = property.time_duration.to_s 
    elsif property.is_a? ServiceLevel
      value = property.service_level
    else
      value = property.value  
    end
        
    # anything other properties for OtherDifferentiatedProperties?
    xml.tag! property.class.to_s, value, attributes     
    
  end

  @usage_record.resource_types.each do |type|
    attributes = {}
    attributes["description"] = type[:description] if type[:description]
    xml.Resource( type.string_value, attributes)
  end
  
  @usage_record.consumable_resource_types.each do |type|
    attrbutes = {}
    attributes["description"] = type[:description] if type[:description]
    attributes["units"] = type[:units] if type[:units]    
    xml.ConsumableResourceType( type.float_value.to_s, attributes )
  end
}

