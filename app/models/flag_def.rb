# == Schema Information
#
# Table name: flag_defs
#
#  id               :integer(4)      not null, primary key
#  flag_type        :string(2)       default(""), not null
#  flag_value       :string(4)       default(""), not null
#  flag_name        :string(30)
#  flag_description :string(255)
#  created_at       :datetime
#  updated_at       :timestamp
#

class FlagDef < ActiveRecord::Base

end
