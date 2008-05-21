class CreateProcessIds < ActiveRecord::Migration
  def self.up
    create_table  :process_ids do |t|
      t.integer   :usage_record_id, :null => false
      t.integer   :value, :null => false
    end
  end

  def self.down
    drop_table    :process_ids
  end
end
