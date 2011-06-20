# == Schema Information
#
# Table name: pool_plates
#
#  id              :integer(11)     not null, primary key
#  project_id      :integer(11)
#  pool_plate_nr   :string(50)
#  pool_plate_desc :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class PoolPlate < InventoryDB
  
  has_many :pool_wells, :foreign_key => "pool_plate_id"
  belongs_to :project
  
  validates_uniqueness_of :pool_plate_nr, :on  => :create 
end
