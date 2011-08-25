# == Schema Information
#
# Table name: misc_plates
#
#  id                :integer(4)      not null, primary key
#  plate_number      :string(4)       default(""), not null
#  plate_description :string(50)
#  synthesis_date    :date
#  updated_at        :timestamp
#

class MiscPlate < ActiveRecord::Base
  has_many :misc_oligos
  
  def self.find_all_incl_oligos(condition_array=nil)
    self.find(:all, :include => :misc_oligos, :order => 'id', :conditions => condition_array)
  end
  
  def self.find_min_and_max_plates
    plate_numbers = self.find(:all).collect{|plate| plate.plate_number[1,2].to_i}
    return plate_numbers.min, plate_numbers.max
  end
  
  def self.find_min_and_max_dates
    synth_dates = self.find(:all, :conditions => "synthesis_date IS NOT NULL").collect(&:synthesis_date)
    return synth_dates.min, synth_dates.max
  end
end
