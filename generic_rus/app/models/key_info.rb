class KeyInfo < ActiveRecord::Base
  
  belongs_to              :signable, :polymorphic => true
  validates_presence_of   :signable

end
  