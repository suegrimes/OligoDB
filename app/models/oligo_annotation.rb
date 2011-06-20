# == Schema Information
#
# Table name: oligo_annotations
#
#  id                :integer(11)     not null, primary key
#  oligo_design_id   :integer(11)     not null
#  oligo_name        :string(100)
#  selector_nr       :integer(11)
#  paralog_flag      :string(2)
#  alu_flag          :string(2)
#  wg_repeat_flag    :string(2)
#  other_repeat_flag :string(2)
#  wg_u0_cnt         :integer(11)     default(0), not null
#  wg_u1_cnt         :integer(11)     default(0), not null
#  paralog_cnt       :integer(11)     default(0), not null
#  version_id        :integer(6)
#  genome_build      :string(25)
#  created_at        :datetime
#  updated_at        :timestamp
#

class OligoAnnotation < ActiveRecord::Base
  
  belongs_to :oligo_design
  
end 
