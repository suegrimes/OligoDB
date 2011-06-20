# == Schema Information
#
# Table name: storage_locations
#
#  id         :integer(11)     not null, primary key
#  room_nr    :string(25)      default(""), not null
#  shelf_nr   :string(25)
#  bin_nr     :string(25)
#  box_nr     :string(25)
#  comments   :string(255)
#  created_at :datetime
#  updated_at :timestamp
#

class StorageLocation < InventoryDB
  
  has_many :oligo_plates,    :foreign_key => :storage_location_id
  has_many :pool_wells,      :foreign_key => :storage_location_id
  
  #validates_uniqueness_of :location_string
  
  def location_string
    [room_nr, shelf_nr, bin_nr, box_nr].join('/')
  end
  
end
