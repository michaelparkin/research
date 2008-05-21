#require 'rubygems'
require 'libxml'

module UsageRecordParser
  
  class Parser
    
    class Callbacks
    
      include XML::SaxParser::Callbacks
    
      attr_accessor :messages, :errors
    
      def initialize
        @record_number = 0
        @messages = {}
        @errors = {}
      end
            
      def normalise_attributes( attributes )
        attributes.each do |k,v|          
          if !k.include?( 'xmlns' ) && k.include?( ':' )
            attributes.delete( k )
            attributes[ k.slice( k.index( ':' ) + 1, k.length ) ] = v
          end
        end
        return attributes
      end
      
      def on_start_element( name, attributes ) 
        attrs = normalise_attributes( attributes )
        case name
        when 'JobUsageRecord', 'UsageRecord'
          @record_number += 1
          @common_props = {}
          @differentiated_props = {}
          @extension_props = {}
        when 'RecordIdentity'
          @in_record_identity = true
          @record_identity = attrs["recordId"]          
          @common_props[:record_identity] = @record_identity
          @common_props[:record_create_time] = attrs["createTime"]
        when 'UserIdentity'
          @in_user_identity = true
          @current_user_identity = {}
        when "ds:KeyInfo"
          @current_key_info = {}
        when 'JobName'
          @common_props[:job_name_description] = attrs["description"]    
        when 'Charge'
          @common_props[:charge_description] = attrs["description"]    
          @common_props[:charge_unit] = attrs["unit"]
          @common_props[:charge_formula] = attrs["formula"]
        when 'Status'
          @common_props[:status_description] = attrs["description"]
        when 'WallDuration'
          @common_props[:wall_duration_description] = attrs["description"]
        when 'EndTime'
          @common_props[:end_time_description] = attrs["description"]
        when 'StartTime'
          @common_props[:start_time_description] = attrs["description"]
        when 'MachineName'
          @common_props[:machine_name_description] = attrs["description"]
        when 'Host'
          @common_props[:host_description] = attrs["description"]
          @common_props[:primary_host] = attrs["primary"]
        when 'SubmitHost'
          @common_props[:submit_host_description] = attrs["description"]
        when 'Queue'
          @common_props[:queue_description] = attrs["description"]
        when 'ProjectName'
          @common_props[:project_name_description] = attrs["description"]
        when 'Network'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]
          @current_hash[:phase_unit] = attrs["phaseUnit"]
          @current_hash[:storage_unit] = attrs["storageUnit"]
          @current_hash[:metric] = attrs["metric"]
        when 'Disk'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]
          @current_hash[:phase_unit] = attrs["phaseUnit"]
          @current_hash[:storage_unit] = attrs["storageUnit"] 
          @current_hash[:metric] = attrs["metric"]
          @current_hash[:property_type] = attrs["type"]
        when 'Memory'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]
          @current_hash[:phase_unit] = attrs["phaseUnit"]
          @current_hash[:storage_unit] = attrs["storageUnit"]
          @current_hash[:metric] = attrs["metric"]
          @current_hash[:property_type] = attrs["type"]
        when 'Swap'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]
          @current_hash[:phase_unit] = attrs["phaseUnit"]
          @current_hash[:storage_unit] = attrs["storageUnit"]
          @current_hash[:metric] = attrs["metric"]
          @current_hash[:property_type] = attrs["type"]
        when 'NodeCount'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]
          @current_hash[:metric] = attrs["metric"]
        when 'Processors'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]
          @current_hash[:metric] = attrs["metric"]
          @current_hash[:consumption_rate] = attrs["consumptionRate"]
         when 'CpuDuration'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]
          @current_hash[:property_type] = attrs["usageType"]                                
        when 'TimeDuration'
          @current_hash = {}
          @current_hash[:property_type] = attrs["type"]
        when 'TimeInstant'
          @current_hash = {}
          @current_hash[:property_type] = attrs["type"]
        when 'ServiceLevel'
          @current_hash = {}
          @current_hash[:property_type] = attrs["type"]
        when 'ResourceType', 'Resource', 'Resources'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]        
        when 'ConsumableResourceType', 'ConsumableResource', 'ConsumableResources'
          @current_hash = {}
          @current_hash[:description] = attrs["description"]        
          @current_hash[:units] = attrs["units"]                
        end
        @current_element = name
      end

      def on_characters( text)
        case @current_element
        when 'GlobalJobId'
          @common_props[:global_job_identity] = text
        when 'LocalJobId'
          @common_props[:local_job_identity] = text
        when 'ProcessId'
          ( @process_ids ||= [] ) << text
        when 'LocalUserId'
          @current_user_identity[:local_user_identity] = text
        when 'GlobalUserName'
          @current_user_identity[:global_user_name] = text
        when 'X509SubjectName'
          @current_key_info[:key_name] = text
        when 'X509IssuerSerial'
          @current_key_info[:key_issuer_serial] = text
        when 'X509Ski'
          @current_key_info[:key_ski] = text
        when 'X509Certificate'
          @current_key_info[:key_certificate] = text
        when 'JobName'
          @common_props[:job_name] = text
        when 'Charge'
          @common_props[:charge] = text
        when 'Status'
          @common_props[:status] = text.capitalize        
        when 'WallDuration'
          @common_props[:wall_duration] = text
        when 'EndTime'
          @common_props[:end_time] = text
        when 'StartTime'
          @common_props[:start_time] = text
        when 'MachineName'
          @common_props[:machine_name] = text
        when 'Host'
          @common_props[:host] = text
        when 'SubmitHost'
          @common_props[:submit_host] = text
        when 'Queue'
          @common_props[:queue] = text
        when 'ProjectName'
          @common_props[:project_name] = text    
        when 'Network'
          @current_hash[:value] = text
        when 'Disk'
          @current_hash[:value] = text
        when 'Memory'
          @current_hash[:value] = text
        when 'Swap'
          @current_hash[:value] = text
        when 'NodeCount'
          @current_hash[:value] = text
        when 'Processors'
          @current_hash[:value] = text
        when 'CpuDuration' 
          @current_hash[:time_duration] = text          
        when 'TimeDuration'
          @current_hash[:time_duration] = text
        when 'TimeInstant'
          @current_hash[:time_instant] = text
        when 'ServiceLevel'
          @current_hash[:service_level] = text
        when 'ResourceType', 'Resource', 'Resources'
          @current_hash[:string_value] = text
        when 'ConsumableResourceType', 'ConsumableResource', 'ConsumableResources'
          @current_hash[:float_value] = text
        end
        # reset the current element so we don't pick up empty text
        @current_element = nil
      end

      def on_end_element( name )
        case name
        when 'JobUsageRecord', 'UsageRecord'
          save_usage_record
        when 'RecordIdentity'
          @in_record_identity = false
        when 'UserIdentity'
          @in_user_identity = false                             
          ( @user_identities ||= [] ) << @current_user_identity unless @current_user_identity.empty? 
        when 'ds:KeyInfo'
          unless @current_key_info.empty?
            if @in_record_identity
              @key_info = @current_key_info                                      
            elsif @in_user_identity
              @current_user_identity[:key_info] = @current_key_info 
            end          
          end
        when 'Network'
          add_properties( @differentiated_props, :networks, :value, @current_hash )          
        when 'Disk'
          add_properties( @differentiated_props, :disks, :value, @current_hash )
        when 'Memory'
          add_properties( @differentiated_props, :memories, :value, @current_hash )
        when 'Swap'
          add_properties( @differentiated_props, :swaps, :value, @current_hash )
        when 'NodeCount'
          add_properties( @differentiated_props, :node_counts, :value, @current_hash )
        when 'Processors'
          add_properties( @differentiated_props, :processors, :value, @current_hash )      
        when 'CpuDuration'
          add_properties( @differentiated_props, :cpu_durations, :time_duration, @current_hash )                
        when 'TimeDuration'
          add_properties( @differentiated_props, :time_durations, :time_duration, @current_hash )                      
        when 'TimeInstant'          
          add_properties( @differentiated_props, :time_instants, :time_instant, @current_hash )                          
        when 'ServiceLevel'
          add_properties( @differentiated_props, :service_levels, :service_level, @current_hash )                                    
        when 'ResourceType', 'Resource', 'Resources'
          add_properties( @extension_props, :resource_types, :string_value, @current_hash )          
        when 'ConsumableResourceType', 'ConsumableResource', 'ConsumableResources' 
          add_properties( @extension_props, :consumable_resource_types, :float_value, @current_hash )        
        end    
      end 
                   
      private                   
      def save_usage_record
        begin                          
          id = UsageRecord.create( params )
          @messages[@record_number] = [ 'The record was assigned the identity ' + id, @record_identity ] if new_record_identity?
        rescue Exception => e       
          @errors[@record_number] = [ e.to_s, @record_identity]
        end                        
      end
      
      def params
        {
          :common_props => @common_props,
          :user_identities => @user_identities,
          :process_ids => @process_ids,
          :key_info => @key_info,
          :differentiated_props => ( @differentiated_props.empty? ? nil : @differentiated_props ),
          :extension_props => ( @extension_props.empty? ? nil : @extension_props )
        }
      end
      
      def add_properties( props, sym, value, hash )
        ( props[sym] ||= [] ) << hash unless hash[value].nil? || hash[value].empty?
      end
            
      def new_record_identity?      
        true if @record_identity.nil? || @record_identity.empty?
      end

    end

    def initialize
      @xp = XML::SaxParser.new
      @xp.callbacks = Callbacks.new
    end
    
    def parse( data )
      @xp.string = data
      @xp.parse
      return @xp.callbacks.messages, @xp.callbacks.errors
    end
    
  end
        
  module_function

  def parse( data )
    return Parser.new.parse( data )
  end
  
end

#require 'benchmark'
#data = "<JobUsageRecords>"
#data << File.new(ARGV[0]).read
#data << File.new(ARGV[0]).read
#data << "</JobUsageRecords>"

#Benchmark.bmbm(7) do |x| 
#  x.report("parsing: ") { UsageRecordParser.parse( data )  }
#end
