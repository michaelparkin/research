class CreateKeyInfos < ActiveRecord::Migration
  def self.up
    create_table  :key_infos do |t|
      t.integer   :signable_id, :null => false
      t.string    :signable_type, :null => false
      t.string    :key_issuer_serial 
      t.string    :key_name 
      t.string    :key_ski 
      t.string    :key_certificate
    end
  end

  def self.down
    drop_table    :key_infos
  end
end
