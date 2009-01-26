class PoolWell < ActiveRecord::Base
  require 'fastercsv'
  
  belongs_to :pool_plate, :foreign_key => "pool_plate_id"
  has_many :aliquots, :foreign_key => "pool_well_id"
  
  validates_uniqueness_of :pool_well_nr, :scope => "pool_plate_id", :on => :create
  
end
