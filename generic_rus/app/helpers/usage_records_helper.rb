require 'erubis/helpers/rails_form_helper'  
require 'usage_record/utils'

module UsageRecordsHelper
  
  include Erubis::Helpers::RailsFormHelper
  
  def sort_td_class_helper( param )
    result = 'class="sortup"' if params[:sort_by] == param
    result = 'class="sortdown"' if params[:sort_by] == param && params[:sort_mode] == "descending"
    return result
  end
  
  def sort_link_helper( text, attribute )
  
    url_hash = {
      :action => 'list', 
      :params => params.merge( { :sort_by => attribute, :page => nil, :sort_mode => get_sort_mode( attribute ) } )
    }
    
    options = {
        :url => url_hash,
        :update => 'table',
        :before => "Element.show('spinner')",
        :success => "Element.hide('spinner')"
    }
    
    html_options = {
      :title => "Sort by this field",
      :href => url_for( url_hash )
    }
        
    link_to_remote( text, options, html_options )
  end
  
  def get_top_links
    get_links( true )
  end
  
  def get_bottom_links
    get_links( false )
  end
          
  private 
  def get_sort_mode( attribute )
    if params[:sort_by] == attribute
      if params[:sort_mode] == "descending"
        sort_mode = nil
      else
        sort_mode = "descending"
      end
    end
  end
  
  def get_links( top )
    
    links = "<small>".concat( top ? "<a href=\"#bottom\">Bottom</a>" : "<a href=\"#top\">Top</a>" ) 
    links.concat( " | <a href=\"#common_properties\">Common properties</a>" )
    
    unless @usage_record.key_info.nil?
      links.concat( " | <a href =\"#key_info\">X509 Key Information</a>" )
    end
    
    unless @usage_record.user_identities.empty?
      links.concat( " | <a href=\"#user_identities\">User Identitites</a>" )
    end
        
    unless @usage_record.differentiated_properties.empty?
      links.concat( " | <a href=\"#differentiated_properties\">Differentiated properties</a>" )
    end
    
    unless @usage_record.resource_types.empty?
      links.concat( " | <a href=\"#extension_properties\">Extension properties</a>" )
    end 
    
    return links.concat( " | ").concat( link_to( "All usage records", usage_records_path ) ).concat( "</small>" )
  end
  
end
