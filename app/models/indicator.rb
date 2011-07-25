# == Schema Information
#
# Table name: indicators
#
#  id                  :integer(4)      not null, primary key
#  last_oligo_plate_nr :integer(4)
#  last_pool_plate_nr  :integer(4)
#

class Indicator < InventoryDB
  
  def self.find_and_increment_pool_plate
    pool_plate_nr = self.find(1).last_pool_plate_nr + 1
    self.update(1, :last_pool_plate_nr => pool_plate_nr)
    
    return pool_plate_nr
  end
end
