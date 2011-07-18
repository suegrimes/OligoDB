class MiscOligo < ActiveRecord::Base
  belongs_to :misc_plate
  
  OLIGO_TYPE = {:V => 'Vector', :A => 'Adapter', :P => 'Primer', :S => 'Selector', :O => 'Other Oligo'}
  
  def oligo_type_descr
    (oligo_type.blank? ? 'Unknown' : OLIGO_TYPE[oligo_type.to_sym])
  end
  
  def self.find_all_incl_plate(condition_array=nil)
    self.find(:all, :include => :misc_plate, :order => 'misc_oligos.misc_plate_id, misc_oligos.well_order',
                         :conditions => condition_array)
  end
end
