class PoolPlate < ActiveRecord::Base
  has_many :pool_wells, :foreign_key => "pool_plate_id"
end
