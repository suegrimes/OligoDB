# == Schema Information
#
# Table name: target_regions
#
#  id                    :integer(4)      not null, primary key
#  gene_id               :integer(4)      not null
#  gene_roi              :string(50)
#  fold_coverage         :integer(2)
#  cds_codes             :string(255)
#  chr_roi_start         :integer(4)
#  chr_roi_stop          :integer(4)
#  roi_strand            :integer(2)
#  chr_target_start      :integer(4)
#  target_roi_start      :integer(4)
#  target_roi_stop       :integer(4)
#  target_seq_clean      :text
#  target_seq_degenerate :text
#  version_id            :integer(4)
#  genome_build          :string(25)
#  created_at            :datetime
#  updated_at            :timestamp
#

class TargetRegion < ActiveRecord::Base
  has_many :ccds
  
  named_scope :curr_ver, :conditions => ['version_id = (?)', Version::DESIGN_VERSION_ID ]
end
