# == Schema Information
#
# Table name: misc_oligos
#
#  id            :integer(4)      not null, primary key
#  oligo_name    :string(100)     default(""), not null
#  oligo_type    :string(2)
#  sequence      :string(100)     default(""), not null
#  misc_plate_id :integer(4)
#  plate_number  :string(4)
#  well_order    :integer(2)      not null
#  notes         :string(100)
#  updated_at    :timestamp
#

class MiscOligo < ActiveRecord::Base
  belongs_to :misc_plate
  has_many :misc_pool_oligos
  has_many :misc_pools, :through => :misc_pool_oligos
  
  OLIGO_TYPE = {:V => 'Vector', :A => 'Adapter', :P => 'Primer', :S => 'Selector', :O => 'Other Oligo'}
  
  def oligo_type_descr
    (oligo_type.blank? ? 'Unknown' : OLIGO_TYPE[oligo_type.to_sym])
  end
  
  def self.find_all_incl_plate(condition_array=nil)
    self.find(:all, :include => :misc_plate, :order => 'misc_oligos.misc_plate_id, misc_oligos.well_order',
                         :conditions => condition_array)
  end
end
