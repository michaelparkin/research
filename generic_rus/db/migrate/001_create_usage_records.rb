class CreateUsageRecords < ActiveRecord::Migration
  def self.up
    create_table  :usage_records do |t|
      
      # just need the created at as the record will never be updated
      t.timestamp :created_at
      
      # Properties defined in Section 11 of GFD-0.98
      t.string    :record_identity, :null => false
      t.datetime  :record_create_time
      t.string    :global_job_identity
      t.string    :local_job_identity      
      t.string    :job_name
      t.string    :job_name_description
      t.float     :charge
      t.string    :charge_description
      t.string    :charge_unit
      t.string    :charge_formula
      t.string    :status, :null => false
      t.string    :status_description
      t.string    :wall_duration          # check type : should be duration
      t.string    :wall_duration_description
      t.timestamp :end_time
      t.string    :end_time_description
      t.timestamp :start_time
      t.string    :start_time_description
      t.string    :machine_name
      t.string    :machine_name_description
      t.string    :host
      t.string    :host_description
      t.boolean   :primary_host
      t.string    :submit_host
      t.string    :submit_host_description
      t.string    :queue
      t.string    :queue_description
      t.string    :project_name
      t.string    :project_name_description
    end
  end

  def self.down
    drop_table    :usage_records
  end
end
