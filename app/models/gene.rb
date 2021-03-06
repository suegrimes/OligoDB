# == Schema Information
#
# Table name: genes
#
#  id               :integer(4)      not null, primary key
#  accession_nr     :string(25)
#  gene_code        :string(25)      default(""), not null
#  chromosome_nr    :integer(2)
#  nr_exons         :integer(3)
#  gene_description :text
#  version_id       :integer(4)
#  genome_build     :string(25)
#  created_at       :datetime
#  updated_at       :datetime
#

class Gene < ActiveRecord::Base
end
