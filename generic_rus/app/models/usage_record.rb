class UsageRecord < ActiveRecord::Base 
  
  require 'usage_record/guid'
    
  CANNOT_DESTROY          = 'Cannot delete a usage record'
  NOT_FOUND               = 'Could not find usage record with id '
  NO_ID_GIVEN             = 'No record identity was supplied' 
  
  has_one                 :key_info, :as => :signable 
  has_many                :process_ids
  has_many                :user_identities
  has_many                :differentiated_properties
  has_many                :resource_types
  has_many                :consumable_resource_types
  validates_presence_of   :status 
  validates_presence_of   :record_identity
  validates_uniqueness_of :record_identity
  
  before_validation       :check_for_record_identity
  before_destroy          :cannot_destroy
  
  is_indexed :fields => [ 'record_identity', 'record_create_time', 
    'global_job_identity', 'local_job_identity', 'job_name', 
    'job_name_description', 'charge', 'charge_description', 
    'charge_unit', 'charge_formula', 'status', 'status_description', 
    'wall_duration', 'wall_duration_description', 'end_time', 
    'end_time_description', 'start_time', 'start_time_description', 
    'machine_name', 'machine_name_description', 'host', 'host_description', 
    'primary_host', 'submit_host', 'submit_host_description', 'queue', 
    'queue_description', 'project_name', 'project_name_description', 
    { :field => 'created_at', :as => 'uploaded_at'} ]
    
  def self.create( params )  
    UsageRecord.transaction do 
            
      # common properties
      usage_record = UsageRecord.new( params[:common_props] )      
      
      # process_ids      
      process_ids = ProcessId.get_all( usage_record, params[:process_ids] )
      usage_record.process_ids = process_ids unless process_ids.nil?
      
      # key info
      key_info = params[:key_info] 
      unless key_info.nil? || key_info.empty?  
        key_info[:signable] = usage_record             
        usage_record.key_info = KeyInfo.new( key_info ) 
      end

      # user identities
      user_idents = UserIdentity.get_all( usage_record, params[:user_identities] )
      usage_record.user_identities = user_idents unless user_idents.nil?
      
      # differentiated properties
      diff_props = DifferentiatedProperty.get_all( usage_record, params[:differentiated_props] )
      usage_record.differentiated_properties = diff_props unless diff_props.nil?
      
      # resource_types/extension properties
      ext_props = ResourceType.get_all( usage_record, params[:extension_props] )      
      usage_record.resource_types = ext_props unless ext_props.nil?
      
      # save and return identity
      usage_record.save!              
      usage_record.record_identity
    end
  end
  
  def self.search( query, page, sort_by, sort_mode )
    if query.nil? || query.empty?
      return_all_paginated( page, sort_by, sort_mode )
    else
      search_with_sphinx( query, page, sort_by, sort_mode )
    end
  end
  
  def self.fetch( record_identity )           
    usage_record = UsageRecord.find_by_record_identity( record_identity )
    return usage_record if usage_record
    error = record_identity.blank? ? error = NO_ID_GIVEN : NOT_FOUND + record_identity.to_s        
    raise ActiveRecord::RecordNotFound.new( error )     
  end
  
  private
  def check_for_record_identity   
    # assume that the GUID will always be unique
    # and not conflict with anything in the DB
    self.record_identity = Guid.new.to_s if self.record_identity.blank?
  end
  
  def cannot_destroy
    raise ActiveRecord::ActiveRecordError.new( CANNOT_DESTROY )
  end
  
  def self.add_process_ids( usage_record, process_ids )
  end
  
  def self.return_all_paginated( page, sort_by, sort_mode )
    order = (sort_by.nil? || sort_by.empty?) ? 'created_at' : sort_by + ' ' + sort_mode   
    paginate :per_page => 10,
             :page => page,
             :order => order
  end
  
  def self.search_with_sphinx( query, page, sort_by, sort_mode )         
    #Ultrasphinx::Search.new( 
    #  :query => query || "", 
    #  :page => page || 1, 
    #  :sort_by => sort_by || 'uploaded_at', 
    #  :sort_mode => sort_mode || 'ascending' 
    #).run
  end
    
end
