# == Schema Information
#
# Table name: subpools
#
#  id            :integer(4)      not null, primary key
#  pool_well_id  :integer(4)      not null
#  pool_id       :integer(4)      not null
#  nr_oligos     :integer(4)
#  ul_to_pool    :decimal(9, 4)
#  oligo_conc_nm :decimal(9, 4)
#  created_at    :datetime
#  updated_at    :timestamp
#

class Subpool < InventoryDB
  
  belongs_to :pool
  belongs_to :pool_well
  
  def ul_chgd_and_conc_not_chgd?(params)
    ul_chgd = !params[:ul_to_pool].blank? && (params[:ul_to_pool].to_d != ul_to_pool)
    conc_chgd = !params[:oligo_conc_nm].blank? && (params[:oligo_conc_nm].to_d != oligo_conc_nm)
    return (ul_chgd && !conc_chgd)
  end
  
  def self.find_all_with_dtls(condition_array)
    self.find(:all,
              :include => {:pool_well => {:aliquots => {:oligo_well => :synth_oligo}}},
              :conditions => condition_array)
  end
  
  # Delete next method if more general method which handles one id or array of ids, is working
  def self.upd_oligo_conc_one_id(pool_id)
    @subpools = self.find(:all,
                          :conditions => ["subpools.pool_id = ?", pool_id])
                          
    pool_vol = @subpools.map {|subpool| subpool.ul_to_pool}.sum
    source_conc = Pool.find(pool_id).source_conc_um
    
    @subpools.each do |subpool|
      # Calculate concentration of individual oligo in subpool
      subpool_conc_um =  source_conc / subpool.nr_oligos
      pool_conc_um    = (subpool_conc_um * subpool.ul_to_pool) / pool_vol
      subpool.update_attributes(:oligo_conc_nm => pool_conc_um * 1000 )
    end
  end
  
  def self.upd_oligo_conc(pool_id_or_ids)
    pool_ids = pool_id_or_ids.to_a 
    @subpools = self.find(:all,
                          :conditions => ["subpools.pool_id IN (?)", pool_ids],
                          :order => "subpools.pool_id")
    @subpools_bypool = @subpools.group_by {|subpool| subpool.pool_id }
    
    @subpools_bypool.sort.each do | pool_id, subpools|
      pool_vol = subpools.map {|subpool| subpool.ul_to_pool}.sum
      source_conc = Pool.find(pool_id).source_conc_um
      
      subpools.each do |subpool|
        # Calculate concentration of individual oligo in subpool
        subpool_conc_um =  source_conc / subpool.nr_oligos
        pool_conc_um    = (subpool_conc_um * subpool.ul_to_pool) / pool_vol
        subpool.update_attributes(:oligo_conc_nm => pool_conc_um * 1000 )
      end
    end
  end
  
  def self.del_oligo_conc(pool_ids)
    @subpools = self.find(:all,
                          :conditions => ["subpools.pool_id IN (?)", pool_ids],
                          :order => "subpools.pool_id")
    @subpools.each do |subpool|
      subpool.update_attributes(:oligo_conc_nm => 0)
    end
  end
  
end
