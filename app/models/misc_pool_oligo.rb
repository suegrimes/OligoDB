# == Schema Information
#
# Table name: misc_pool_oligos
#
#  id            :integer(4)      not null, primary key
#  misc_oligo_id :integer(4)      default(0), not null
#  misc_pool_id  :integer(4)      default(0), not null
#  volume        :decimal(11, 3)
#  created_at    :datetime
#  updated_at    :datetime
#

class MiscPoolOligo < ActiveRecord::Base
  has_many :misc_oligos
  has_many :misc_pools
  
end
