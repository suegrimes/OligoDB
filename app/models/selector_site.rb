# == Schema Information
#
# Table name: selector_sites
#
#  id               :integer(4)      not null, primary key
#  target_region_id :integer(4)      not null
#  enzyme_code      :string(20)      default(""), not null
#  n_sites_start    :integer(1)      not null
#  left_site_used   :integer(1)
#  right_site_used  :integer(1)
#  selector         :string(255)
#  design_result    :string(255)     default(""), not null
#  version_id       :integer(4)
#  genome_build     :string(25)
#  created_at       :datetime
#  updated_at       :datetime
#

class SelectorSite < ActiveRecord::Base
  named_scope :curr_ver, :conditions => ['version_id = (?)', Version::DESIGN_VERSION_ID ]
end
