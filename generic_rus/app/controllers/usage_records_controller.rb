class UsageRecordsController < ApplicationController
    
  require 'usage_record/urparser'
              
  # GET /usage_records
  # GET /usage_records.xml
  def index                
    @usage_records = UsageRecord.search( params[:query], params[:page], params[:sort_by], params[:sort_mode] )
    respond_to do |format|
      format.html           
      format.xml { response.headers["Content-Type"] = Mime::USAGE_RECORD_DOC }
      format.atom     
      format.js do
        render :update do |page|
          page.replace_html 'results', :partial => 'usage_records'
        end        
      end      
    end    
  end
      
  # GET /usage_records/1
  # GET /usage_records/1.xml
  def show
    @usage_record = UsageRecord.fetch( params[:id] )  
    respond_to do |format|
      format.html     
      format.xml { response.headers["Content-Type"] = Mime::USAGE_RECORD_DOC }      
    end
  end
      
  # POST /usage_records
  # POST /usage_records.xml
  def create    
    if request.content_type == Mime::USAGE_RECORD_DOC
      if request.content_length > 0
        @messages, @errors = UsageRecordParser::parse( request.raw_post )   
        respond_to do |format|   
          format.xml { render :xml => 'create.xml', :status => ( @errors.empty? ? :created : :unprocessable_entity ) }
        end
      else
        raise BadRequestException.new( "There is no content to process" )
      end
    else
      raise BadRequestException.new( "The content-type of the message should be " + Mime::USAGE_RECORD_DOC )
    end
  end
  
  # PUT /usage_records/1
  # PUT /usage_records/1.xml
  def update    
    respond_to do |format|
      flash[:notice] = UsageRecord::CANNOT_UPDATE 
      format.html { redirect_to usage_records_path, :status => :forbidden }
      format.xml  { render :template => 'layouts/fault.rxml', :layout => false, :status => :forbidden } 
    end
  end
  
  # DELETE /usage_records/1
  # DELETE /usage_records/1.xml
  def destroy    
    respond_to do |format|
      flash[:notice] = UsageRecord::CANNOT_DESTROY 
      format.html { redirect_to usage_records_path, :status => :forbidden }
      format.xml  { render :template => 'layouts/fault.xml', :layout => false, :status => :forbidden } 
    end
  end
  
  private
  def rescue_action( exception )   
    flash[:notice] = exception.to_s.capitalize   
    case exception
    when ActiveRecord::RecordNotFound # can't find a usage_record 
      respond_to do |format|
        format.html { render :template => 'usage_records/404.html.erb', :status => :not_found }
        format.xml  { render :template => 'layouts/fault', :layout=> false, :status => :not_found }
      end
    when BadRequestException # user didn't post a usage record
      respond_to do |format|
        #format.html { render :template => 'usage_records/406.html.erb', :status => :not_acceptable } #:unsupported_media_type?
        format.xml  { render :template => 'layouts/fault.xml.builder', :layout => false, :status => :not_acceptable }
      end
    else # other errors  
      #respond_to do |format|
      #  format.html { render :template => 'usage_records/500.html.erb', :status => :internal_server_error }
      #  format.xml  { render :template => 'layouts/fault.xml.builder', :layout=> false, :status => :internal_server_error }
      #end
      raise exception
    end
  end
  
end
