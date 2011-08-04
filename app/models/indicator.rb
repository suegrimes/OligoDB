# == Schema Information
#
# Table name: indicators
#
#  id                  :integer(4)      not null, primary key
#  last_oligo_plate_nr :integer(4)
#  last_pool_plate_nr  :integer(4)
#

class Indicator < InventoryDB
  DISPLAY_MENU = {:designs => 0, :synthesis => 0, :plates => 0, :pools => 0, :supporting => 0, :help => 0}
  MENU_MAPPING = {:designs => %w{oligo_designs pilot_oligo_designs archive_oligo_designs},
                  :synthesis => %w{synth_oligos synth_orders uploads},
                  :plates => %w{oligo_plates oligo_wells},
                  :pools => %w{pool_plates pool_wells subpools pools},
                  :supporting => %w{projects researchers storage_locations vectors versions flag_defs users},
                  :help => ['help']}
  
  def self.find_and_increment_pool_plate
    pool_plate_nr = self.find(1).last_pool_plate_nr + 1
    self.update(1, :last_pool_plate_nr => pool_plate_nr)
    
    return pool_plate_nr
  end
end
