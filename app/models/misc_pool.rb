# == Schema Information
#
# Table name: misc_pools
#
#  id                  :integer(4)      not null, primary key
#  pool_name           :string(50)      default(""), not null
#  tube_label          :string(50)
#  pool_description    :string(255)
#  source_conc_um      :decimal(6, 1)
#  storage_location_id :integer(4)
#  comments            :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class MiscPool < ActiveRecord::Base
  has_many :misc_pool_oligos
  has_many :misc_oligos, :through => :misc_pool_oligos
  belongs_to :storage_location
  
  accepts_nested_attributes_for :misc_pool_oligos
  
  validates_presence_of :tube_label
end
