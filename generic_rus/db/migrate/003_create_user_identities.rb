class CreateUserIdentities < ActiveRecord::Migration
  def self.up
    create_table  :user_identities do |t|
      t.integer   :usage_record_id, :null => false    
      t.string    :local_user_identity
      t.string    :global_user_name
    end
  end

  def self.down
    drop_table    :user_identities
  end
end
