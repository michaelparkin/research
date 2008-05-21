class CreateResourceTypes < ActiveRecord::Migration
  def self.up
    create_table  :resource_types do |t|
      t.integer   :usage_record_id, :null => false
      t.string    :type           # because we're using STI
      t.string    :string_value   # resource type values
      t.float     :float_value    # consumable resource type values
      t.string    :description
      t.string    :units
    end
  end

  def self.down
    drop_table    :resource_types
  end
end
