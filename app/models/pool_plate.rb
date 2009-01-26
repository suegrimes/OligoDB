class PoolPlate < ActiveRecord::Base
  has_many :pool_wells, :foreign_key => "pool_plate_id"
  
  validates_uniqueness_of :pool_plate_nr, :on  => :create 
end
