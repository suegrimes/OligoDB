# == Schema Information
#
# Table name: ccds
#
#  id               :integer(10)     not null, primary key
#  target_region_id :integer(11)     not null
#  ccds_code        :string(20)      default(""), not null
#  version_id       :integer(11)
#  genome_build     :string(25)
#  created_at       :datetime
#  updated_at       :datetime
#

class Ccds < ActiveRecord::Base
  belongs_to :target_region
end
