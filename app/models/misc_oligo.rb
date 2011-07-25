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
  
  OLIGO_TYPE = {:V => 'Vector', :A => 'Adapter', :P => 'Primer', :S => 'Selector', :O => 'Other Oligo'}
  WELL_LETTER = %w{A B C D E F G H}
  
  def oligo_type_descr
    (oligo_type.blank? ? 'Unknown' : OLIGO_TYPE[oligo_type.to_sym])
  end
  
  def well_coord
    well_alpha = WELL_LETTER[(well_order - 1)/12]
    well_num   = (well_order - 1) % 12 + 1 
    return well_alpha + well_num.to_s
  end
  
  def dna_sequence
    # Delete any of the following characters from ordered oligo: space, P, X, 5, '-', or single quote
    # Convert any lowercase letters to uppercase
    sequence.upcase.gsub(/([' 'PX5\-\'])/, '') 
  end
  
  def self.find_all_incl_plate(condition_array=nil)
    self.find(:all, :include => :misc_plate, :order => 'misc_oligos.misc_plate_id, misc_oligos.well_order',
                         :conditions => condition_array)
  end
end
