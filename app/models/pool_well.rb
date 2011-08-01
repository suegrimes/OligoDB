# == Schema Information
#
# Table name: pool_wells
#
#  id                  :integer(4)      not null, primary key
#  pool_plate_id       :integer(4)      default(0), not null
#  pool_plate_nr       :string(50)
#  pool_well_nr        :string(4)       default(""), not null
#  pool_tube_label     :string(50)
#  enzyme_code         :string(20)
#  description         :string(20)
#  pool_well_volume    :float(11)       default(0.0)
#  nr_oligos           :integer(4)      default(0)
#  ul_to_pool          :float(9)
#  oligo_concentration :float(11)
#  project_id          :integer(4)
#  pool_id             :integer(4)
#  storage_location_id :integer(4)
#  comments            :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

###*** remove ul_to_pool, and pool_id - reside in subpools now since many <-> many relationship
###*** also remove oligo_concentration since it is not a relevant statistic in this entity (moved to subpools)

class PoolWell < InventoryDB
  
  belongs_to :project
  belongs_to :pool_plate
  has_many :aliquots, :foreign_key => "pool_well_id"
  
  has_many :subpools, :dependent => :destroy
  has_many :pools, :through => :subpools
  
  validates_uniqueness_of :pool_well_nr, :scope => "pool_plate_id", :on => :create
  
  PIPETTE_TO_BIOMEK = 5.0
  
  # Later: rename ul_to_pool, to ul_to_biomek.  Then delete this method.
  # Or, delete this field entirely.  Is it needed?  (ul volume exists in aliquots table)
  def ul_to_biomek
    ul_to_pool
  end
  
  # in_pool? returns true if well is attached to a given pool, otherwise false  
  def in_pool?(pool_id)
    @_subpools ||= self.subpools.collect(&:pool_id)
    (@_subpools.include?(pool_id) )
  end
  
  def self.find_for_project_enzyme_and_biomek_string(pool, biomek)
    condition_array = []
    condition_array[0] = ''
    select_conditions = []
    
#    if !pool.project_id.blank?
#      select_conditions.push("project_id = ?")
#      condition_array.push(pool.project_id)
#    end
    
    if !pool.enzyme_code.blank?
      select_conditions.push("enzyme_code = ?")
      condition_array.push(pool.enzyme_code)
    end
    
    if biomek
      select_conditions.push("pool_plate_nr LIKE ?")
      condition_array.push("%#{biomek}%")
    end
    
    condition_array[0] = select_conditions.join(" AND ")
    self.find(:all, :include => :subpools,
              :conditions => condition_array,
              :order => 'pool_plate_nr DESC, pool_well_nr')
  end
  
  def self.find_for_well_and_pool(well_ids, pool_id)
    self.find(:all, :include => [:subpools, :pool_plate], 
              :conditions => ['pool_wells.id IN (?) AND subpools.pool_id = ?', well_ids, pool_id],
              :order => 'pool_wells.description, pool_wells.pool_plate_nr, pool_wells.pool_well_nr')
  end
  
#  def self.upd_oligo_conc(pool_ids)
#    pool_wells = self.find(:all, :joins => [:pool, :aliquots],
#                     :select => "pool_wells.id, pools.id as 'pool_id', pools.source_conc_um, pools.pool_volume," + 
#                                "pool_wells.ul_to_pool, count(aliquots.id) as 'nr_oligos'",
#                     :group => "pool_wells.id",
#                     :conditions => ['pools.id IN (?) AND pools.pool_volume > 0', pool_ids])
#                     
#    pool_wells.each do |well|
#      oligo_conc_nM = ((well.source_conc_um.to_f * well.ul_to_pool.to_f)/well.pool_volume.to_f) * 1000.0
#      PoolWell.update(well.id, :nr_oligos           => well.nr_oligos.to_i,
#                               :oligo_concentration => oligo_conc_nM )
#    end
#  end
  
end
