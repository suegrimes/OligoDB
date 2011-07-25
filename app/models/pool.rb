# == Schema Information
#
# Table name: pools
#
#  id                  :integer(4)      not null, primary key
#  pool_name           :string(50)      default(""), not null
#  tube_label          :string(50)
#  enzyme_code         :string(20)      default(""), not null
#  pool_description    :string(255)
#  source_conc_um      :decimal(6, 1)
#  pool_volume         :decimal(9, 3)   default(0.0)
#  project_id          :integer(4)
#  storage_location_id :integer(4)
#  comments            :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class Pool < InventoryDB
  
  has_many :subpools, :dependent => :destroy
  has_many :pool_wells, :through => :subpools
  has_many :aliquots, :through => :pool_wells
  belongs_to :storage_location
  belongs_to :project
  
  validates_uniqueness_of :pool_name, :on  => :create 
  
  def self.upd_pool_vol(pool_ids)
    @pools = self.find(:all, :joins => :subpools, :select => "pools.id, sum(subpools.ul_to_pool) as 'pool_vol'",
                             :group => "pools.id",  :conditions => ["pools.id IN (?)", pool_ids])
    @pools.each do |pool|
      pool.update_attributes(:pool_volume => pool.pool_vol)
    end
  end
  
end
