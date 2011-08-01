# == Schema Information
#
# Table name: oligo_designs
#
#  id                      :integer(4)      not null, primary key
#  oligo_name              :string(100)     default(""), not null
#  target_region_id        :integer(4)      default(0), not null
#  valid_oligo             :string(1)       default(""), not null
#  chromosome_nr           :string(3)
#  gene_code               :string(25)
#  enzyme_code             :string(20)
#  selector_nr             :integer(3)
#  roi_nr                  :integer(2)
#  internal_QC             :string(2)
#  annotation_codes        :string(20)
#  other_annotations       :string(20)
#  sel_n_sites_start       :integer(1)
#  sel_left_start_rel_pos  :integer(2)
#  sel_left_end_rel_pos    :integer(2)
#  sel_left_site_used      :integer(1)
#  sel_right_start_rel_pos :integer(2)
#  sel_right_end_rel_pos   :integer(2)
#  sel_right_site_used     :integer(1)
#  sel_polarity            :string(1)
#  sel_5prime              :string(30)
#  sel_3prime              :string(30)
#  usel_5prime             :string(30)
#  usel_3prime             :string(30)
#  selector_useq           :string(255)
#  amplicon_chr_start_pos  :integer(4)
#  amplicon_chr_end_pos    :integer(4)
#  amplicon_length         :integer(4)
#  amplicon_seq            :text
#  version_id              :integer(4)
#  genome_build            :string(25)
#  created_at              :datetime
#  updated_at              :datetime
#

class OligoDesign < ActiveRecord::Base
# PilotOligoDesign inherits from this model class, therefore any table name references must be generic, 
# or method must be passed a parameter to indicate which model the method is accessing
  acts_as_commentable
 
  has_one  :oligo_annotation, :foreign_key => :oligo_design_id
  
  validates_uniqueness_of :oligo_name,
                          :on  => :create  
                          
  named_scope :curr_ver, :conditions => ['version_id = (?)', Version::DESIGN_VERSION_ID ]
  named_scope :qcpassed, :conditions => ['(internal_QC IS NULL OR internal_QC = " ")']
  named_scope :notflagged, :conditions => ['(annotation_codes IS NULL OR annotation_codes = " ")']
  
  unique_enzymes = self.curr_ver.find(:all, 
                                      :select => "DISTINCT(enzyme_code)",
                                      :order  => :enzyme_code)
  ENZYMES = unique_enzymes.map{ |design| design.enzyme_code }
  ENZYMES_WO_GAPFILL = ENZYMES.reject { |enzyme| enzyme =~ /.*_gapfill/}
  #VECTOR = 'ACGATAACGGTACAAGGCTAAAGCTTTGCTAACGGTCGAG'

  ZIP_FILE_ROOT = (CAPISTRANO_DEPLOY == true ? File.join(RAILS_ROOT, "..", "..", "shared") :
                                               File.join(RAILS_ROOT, "..", "OligoFiles"))
 
  #****************************************************************************************#
  #  Define virtual attributes                                                             #
  #****************************************************************************************#
  
  def polarity
    (sel_polarity == 'p' ? 'plus' : 'minus')
  end
  
  def vector
    Version::VER_VECTORS.assoc(version_id.to_i)[1][0]
  end
  
  def usel_vector
    Version::VER_VECTORS.assoc(version_id.to_i)[1][1]
  end
  
  def selector
    [sel_5prime, vector, sel_3prime].join('')
  end
  
  def chr_target_start
    (amplicon_chr_start_pos -  sel_left_start_rel_pos + 1)
  end
  
  def roi_ids_of_selectors
    [gene_code, 'ROI', roi_nr].join('_')
  end
  
  #****************************************************************************************#
  #  Class find methods   - Genes/Enzymes                                                  #
  #****************************************************************************************#
  
  def self.unique_genes
    self.curr_ver.find(:all, :select => "gene_code", :group => :gene_code, :order => :gene_code)
  end
  
  ## remove this method, and just do once at beginning of class.  use OligoDesign::ENZYMES in controllers etc.
  def self.unique_enzymes
    self.curr_ver.find(:all, :select => "enzyme_code", :group => :enzyme_code, :order => :enzyme_code)
  end
  
  #****************************************************************************************#
  #  Class find methods   - Oligos                                                         #
  #****************************************************************************************#
  
  def self.find_using_oligo_name_id(oligo_name)
    # Use id or gene_code index to speed retrieval.
    # Note: curr_oligo_format?, and get_gene_from_name are in OligoExtensions module
    
    if curr_oligo_format?(oligo_name)                            
      # oligo name in current format, => use id as index
      oligo_array  = oligo_name.split(/_/)
      oligo_design = self.find_by_oligo_name_and_id(oligo_name, oligo_array[0])
    else
      # oligo name in old format => cannot use id, use gene code instead
      #gene_code    = self.get_gene_from_name(oligo_name, false)
      gene_code    = get_gene_from_oligo_name(oligo_name, false) 
      oligo_design = self.find_by_oligo_name_and_gene_code(oligo_name, gene_code)
    end
    
    return oligo_design
  end
  
  def self.find_oligos_with_conditions(condition_array, version_id=Version::DESIGN_VERSION_ID, opt_hash={})
    options = {:sort_order => 'default', :excl_flagged => 'no'}
    options = options.merge!(opt_hash)
        
    sort_fields = (options[:sort_order] == 'enzyme' ? 'enzyme_code, id' : 'gene_code, enzyme_code')
    model       = Version.find(version_id).oligo_model
    
    if options[:excl_flagged] == 'yes'
      model.constantize.qcpassed.notflagged.find(:all, :order => "#{sort_fields}", 
                                                 :include => :oligo_annotation,
                                                 :conditions => condition_array)
    else
      model.constantize.qcpassed.find(:all, :order => "#{sort_fields}", 
	                                       :include => :oligo_annotation,
	                                       :conditions => condition_array)
    end
  end
  
  def self.find_with_id_list(id_list, version_id=Version::DESIGN_VERSION_ID)
    self.find_oligos_with_conditions(["id IN (?)", id_list])
  end
  
  #****************************************************************************************#
  #  Create synthesis order                                                                #
  #****************************************************************************************#
  
  def self.create_synth_file(researcher, plate_start, nr_wells, oligos)
    date_ymd_ = Time.now.strftime("%y%m%d_")
    date_mdy = Time.now.strftime("%m/%d/%Y")
    
    #Loop through oligo array and write output file(s)
    filecnt = 0
    rownum = 0
    for oligo in oligos do
        # if current row number is zero, or a multiple of "nr_wells", write header
        if rownum % nr_wells.to_i == 0
          # determine plate number, and close previous file, open new output file
          if filecnt == 0
            @plate_nr = "%05d" % plate_start
            synth_file = date_ymd_ + @plate_nr + ("_") + researcher.researcher_initials
            #file_path = File.join(CreatedFile::FILES_ROOT, "#{synth_file}.txt")
            file_path = CreatedFile.new_file_path(synth_file)
            f = File.new(file_path, 'w')
          else
            f.close
           
            @plate_nr = "%05d" % (@plate_nr.to_i + 1).to_s
            synth_file = date_ymd_ + @plate_nr + ("_") + researcher.researcher_initials
            #file_path = File.join(CreatedFile::FILES_ROOT, "#{synth_file}.txt")
            file_path = CreatedFile.new_file_path(synth_file)
            f = File.new(file_path, 'w')
          end
    
          filecnt += 1
      
          # write header
          f.write "\tInstructions:" + 
                  "\t\"Fill in and Save As Text (tab delimited), then upload using web page\"\n\n"
          f.write "\tResearcher:\t" + researcher.researcher_name + "\n"
          f.write "\tDate:\t" + date_mdy + "\n"
          f.write "\tPlate ID:\t" + synth_file + "\n"
          f.write "\n\nNumber\tOligo Name\tSequence\n"
          
          # write file name to CreatedFile model
          CreatedFile.create!(:content_type => "Synthesis",
                              :created_file => synth_file,
                              :researcher_id => researcher.id)
                    
          # update last plate number used
          Indicator.update(1, :last_oligo_plate_nr => @plate_nr.to_i)
             
          # set or increment row number
          rownum = 1
        else
          rownum += 1
        end
        
        # write detail row
        row = rownum.to_s
        f.write row + "\t" + oligo[:oligo_name] + "\t" + oligo[:selector_useq] + "\n"
    end
    f.close
  end

  #****************************************************************************************#
  #  Methods to delete                                                                     #
  #****************************************************************************************#
#  def self.find_using_oligo_name_id1(oligo_name)
#    # Use id to speed retrieval.
#    # Note: curr_oligo_format?, and get_id_from_name are in OligoExtensions module
#    # When working, this should replace the find_using_oligo_name method
#    
#    oligo_id     = get_id_from_oligo_name(oligo_name)
#    oligo_design = self.find_by_oligo_name_and_id(oligo_name, oligo_id)
#    
#    return oligo_design
#  end
  
#  def self.find_selectors_from_gene_list(genes, sort_order='alphabetical', version_id=Version::DESIGN_VERSION_ID)
#    # use maintain_gene_order in dev/test mode, if gene_priority table has been manually created
#    # for specific genes/gene order
#    if sort_order && sort_order == 'gene priority'
#      self.qcpassed.find(:all,                              
#                         :select => 'oligo_name, oligo_designs.gene_code, selector_useq',
#                         :joins => 'right join gene_priority on oligo_designs.gene_code = gene_priority.gene_code',
#                         :conditions => ['version_id = ?', version_id ],
#                         :order => 'priority')
#    else
#      self.qcpassed.find(:all,
#                         :order => 'gene_code, enzyme_code',                               
#                         :select => 'oligo_name, gene_code, selector_useq',
#                         :conditions => ['gene_code IN (?) AND version_id = ?', genes, version_id])
#    end
#    
#  end

#  No longer used; oligo_designs do not link directly to oligo_wells
#  def self.find_with_wells_from_ids(id_list)
#    self.find(:all, :include => :oligo_wells,
#                    :order => 'oligo_designs.gene_code, oligo_designs.enzyme_code, 
#                               oligo_wells.oligo_plate_num, oligo_wells.plate_copy_code',
#                    :conditions => ["oligo_designs.id IN (?)", id_list])
#  end
    
  #****************************************************************************************#
  #  Export to csv file (not used?), doesn't include all fields                            #
  #****************************************************************************************#
  
  def self.export_designs_to_csv(oligo_designs)
    csv_string = FasterCSV.generate(:col_sep => "\t") do |csv|
      csv << %w(OligoName Annot Chromosome Polarity Oligo_5Prime Oligo_3Prime  
                AmpliconStart AmpliconEnd AmpliconLength AmpliconSeq GenomeBuild DesignVersion).to_a
      
      oligo_designs.each do |oligo|
        csv << [oligo[:oligo_name],
                oligo[:annotation_codes],
                oligo[:chromosome_nr],
                oligo[:sel_polarity],
                oligo[:usel_5prime],
                oligo[:usel_3prime],
                oligo[:amplicon_chr_start_pos],
                oligo[:amplicon_chr_end_pos],
                oligo[:amplicon_length],
                oligo[:amplicon_seq],
                oligo[:genome_build],
                oligo[:version_id] ]
      end
    end
    return csv_string
  end
   
end
