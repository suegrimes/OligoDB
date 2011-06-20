# == Schema Information
#
# Table name: target_regions
#
#  id                    :integer(11)     not null, primary key
#  gene_id               :integer(11)     not null
#  gene_roi              :string(50)
#  fold_coverage         :integer(6)
#  cds_codes             :string(255)
#  chr_roi_start         :integer(11)
#  chr_roi_stop          :integer(11)
#  roi_strand            :integer(6)
#  chr_target_start      :integer(11)
#  target_roi_start      :integer(11)
#  target_roi_stop       :integer(11)
#  target_seq_clean      :text
#  target_seq_degenerate :text
#  version_id            :integer(11)
#  genome_build          :string(25)
#  created_at            :datetime
#  updated_at            :timestamp
#

class TargetRegion < ActiveRecord::Base
  has_many :ccds
  
  named_scope :curr_ver, :conditions => ['version_id = (?)', Version::DESIGN_VERSION_ID ]
end
