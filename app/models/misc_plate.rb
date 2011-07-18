class MiscPlate < ActiveRecord::Base
  has_many :misc_oligos
  
  def self.find_all_incl_oligos(condition_array=nil)
    self.find(:all, :include => :misc_oligos, :order => 'id', :conditions => condition_array)
  end
end
