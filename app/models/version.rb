# == Schema Information
#
# Table name: versions
#
#  id                    :integer(4)      not null, primary key
#  version_for_synthesis :string(1)
#  exonome_or_partial    :string(1)
#  genome_build          :string(15)      default(""), not null
#  ccds_build            :string(15)
#  dbsnp_build           :string(15)
#  design_version        :string(15)      default(""), not null
#  version_name          :string(50)
#  vector_id             :integer(4)
#  archive_flag          :string(1)
#  genome_build_notes    :string(255)
#  design_version_notes  :string(255)
#  created_at            :datetime
#  updated_at            :timestamp       not null
#

class Version < ActiveRecord::Base  
  named_scope :curr_version, :conditions => {:version_for_synthesis => 'Y', :exonome_or_partial => 'E', :archive_flag => 'C'},
                                             :order => 'id DESC'
  belongs_to :vector
  
  before_save do |version|
    version.archive_flag = (version.exonome_or_partial == 'E' ? 'C' : 'P')
  end
  
  # Set global variables which are dependent on design version
  @version = self.curr_version.find(:first)
  DESIGN_VERSION_ID = @version.id
  DESIGN_VERSION_NAMES = @version.genome_build + "/" + @version.design_version
  
  BUILD_VERSION_NAMES = self.find(:all).map {|version| [version.id, 
                            [version.exonome_or_partial, version.genome_build, version.design_version].join('/')]}
                            
  VER_VECTORS = self.find(:all, :include => :vector).map {|version| [version.id, [version.vector.vector, version.vector.u_vector]]}
 
  #read App_Versions file to set current application version #
  #version# is first row, first column
  filepath = "#{RAILS_ROOT}/public/app_versions.txt"
  if FileTest.file?(filepath)
    app_version_row1 = FasterCSV.read(filepath, {:col_sep => "\t"})[0]
    end
  APP_VERSION = (app_version_row1 ? app_version_row1[0] : '??')
  
  def version_id_name
    [id.to_s, [exonome_or_partial, genome_build, design_version].join('/')].join('-')
  end
  
  def version_id_flagged_name
    #flag current version with asterisk, for use in select box
    (id == DESIGN_VERSION_ID ? ['*', version_id_name].join('') : [' ', version_id_name].join(''))
  end
  
  def oligo_model
    model = case 
      when exonome_or_partial == 'P' then 'PilotOligoDesign'
      when archive_flag == 'A'       then 'ArchiveOligoDesign'
      else 'OligoDesign'
      end
    return model
  end
  
  def self.version_id_or_default(id_num)
    return (id_num.blank? ? DESIGN_VERSION_ID : id_num.to_i)
  end
  
end
