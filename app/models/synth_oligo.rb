# == Schema Information
#
# Table name: synth_oligos
#
#  id                      :integer(11)     not null, primary key
#  oligo_name              :string(100)     default(""), not null
#  oligo_id                :integer(11)
#  target_region_id        :integer(11)     default(0)
#  valid_oligo             :string(1)
#  chromosome_nr           :string(3)
#  gene_code               :string(25)
#  enzyme_code             :string(20)
#  selector_nr             :integer(9)
#  roi_nr                  :integer(6)
#  internal_QC             :string(2)
#  annotation_codes        :string(20)
#  other_annotations       :string(20)
#  sel_n_sites_start       :integer(4)
#  sel_left_start_rel_pos  :integer(6)
#  sel_left_end_rel_pos    :integer(6)
#  sel_left_site_used      :integer(4)
#  sel_right_start_rel_pos :integer(6)
#  sel_right_end_rel_pos   :integer(6)
#  sel_right_site_used     :integer(4)
#  sel_polarity            :string(1)
#  sel_5prime              :string(30)
#  sel_3prime              :string(30)
#  usel_5prime             :string(30)
#  usel_3prime             :string(30)
#  selector_useq           :string(255)
#  amplicon_chr_start_pos  :integer(11)
#  amplicon_chr_end_pos    :integer(11)
#  amplicon_length         :integer(11)
#  amplicon_seq            :text
#  version_id              :integer(11)
#  genome_build            :string(25)
#  created_at              :datetime
#  updated_at              :datetime
#

class SynthOligo < InventoryDB
  acts_as_commentable  
  
  has_many :oligo_wells, :foreign_key => "synth_oligo_id"
  has_many :oligo_plates, :through => :oligo_wells
  
  named_scope :qcpassed, :conditions => ['(internal_QC IS NULL OR internal_QC = " " )']
  
  ANNOT_DB = ((RAILS_ENV == 'production' || RAILS_ENV == 'staging')? 'oligoDB1' : 'oligoDB')
  
  #****************************************************************************************#
  #  Define virtual attributes                                                             #
  #****************************************************************************************#
  
  def oligo_name_id
    name_array = oligo_name.split(/_/)
    return name_array[0]
  end
  
  def polarity
    (sel_polarity == 'p' ? 'plus' : 'minus')
  end
  
  def vector
    Version::VER_VECTORS.assoc(version_id.to_i)[0]
  end
  
  def usel_vector
    Version::VER_VECTORS.assoc(version_id.to_i)[1]
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
  #  Class find methods                                                                    #
  #****************************************************************************************#
  
  def self.find_id_incl_annot(id)
    self.find(id, :select => "synth_oligos.*, " +
                             "#{ANNOT_DB}.oligo_annotations.paralog_cnt, " +
                             "#{ANNOT_DB}.oligo_annotations.wg_u0_cnt, " +
                             "#{ANNOT_DB}.oligo_annotations.wg_u1_cnt",
                  :joins => "LEFT JOIN #{ANNOT_DB}.oligo_annotations ON synth_oligos.oligo_id = #{ANNOT_DB}.oligo_annotations.oligo_design_id")
  end
  
  def self.find_with_id_list(id_list)
    self.qcpassed.find(:all, 
                       :select => "synth_oligos.*, " + 
                                  "#{ANNOT_DB}.oligo_annotations.paralog_cnt, " +
                                  "#{ANNOT_DB}.oligo_annotations.wg_u0_cnt, " +
                                  "#{ANNOT_DB}.oligo_annotations.wg_u1_cnt",
                       :joins => "LEFT JOIN #{ANNOT_DB}.oligo_annotations ON synth_oligos.oligo_id = #{ANNOT_DB}.oligo_annotations.oligo_design_id",
                       :order => 'gene_code, enzyme_code',
                       :conditions => ["synth_oligos.id IN (?)", id_list])
  end
  
  def self.find_id_name_with_conditions(cond_array)
    self.qcpassed.find(:all, :select => 'id, synth_oligos.oligo_name',
                       :conditions => cond_array)
  end
  
  def self.find_using_oligo_name(oligo_name)
    #Use gene code to speed retrieval since gene code is indexed.
    oligo_name ||= '1_Gene_ROI_1_MseI'
    
    gene_code = get_gene_from_oligo_name(oligo_name)
    self.find_by_oligo_name_and_gene_code(oligo_name, gene_code)
  end
  
  def self.find_plate_wells_with_conditions(cond_array)
    self.qcpassed.find(:all, :include => [{:oligo_wells => {:oligo_plate => :storage_location}}],
                    :order => 'synth_oligos.gene_code, synth_oligos.enzyme_code,
                               oligo_wells.oligo_plate_num, oligo_wells.plate_copy_code',                   
                    :conditions => cond_array)
  end
  
  #****************************************************************************************#
  #  Load of synthesized oligos                                                            #
  #****************************************************************************************#
  
  def self.loadoligos(file_path)
    plate_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3]   
    
    # Read csv file, and store in array
    # Start reading at line 9, since earlier lines are header information
    begin
      oligos = FasterCSV.read(file_path, {:col_sep => "\t"})[8..-1]
      
      rescue FasterCSV::MalformedCSVError
      logger.error "File: #{file_path} is not in CSV format"
      return -2
    end
      
     # Read oligos and create synthesis record.  Break from loop with premature eof message
     # if oligo name is null or blank (This occurs with last plate of a synthesis order, if the
     # plate is not full).
     begin
     oligos.each do |row| 
       
       if (row[2].nil? || row[2].empty? || row[2].length < 6)
        logger.info "Premature end of file at plate: #{plate_row[1]}, row: #{row[1]}"
        eof_reached = true
       else
         @oligo_name    = row[2]
         synth_oligo    = self.find_using_oligo_name(@oligo_name)
       end
       
       break if eof_reached
      
       if synth_oligo.nil?
         o_design = OligoDesign.find_using_oligo_name_id(@oligo_name)         
         design = (o_design.nil? ? PilotOligoDesign.find_using_oligo_name_id(@oligo_name) : o_design)
         
         raise ActiveRecord::RecordNotFound  if design.nil?
       
         @synth_oligo = self.new(:oligo_name  => design.oligo_name,
                            :oligo_id         => design.id,
                            :valid_oligo      => design.valid_oligo,
                            :chromosome_nr    => design.chromosome_nr,
                            :gene_code        => design.gene_code,
                            :enzyme_code      => design.enzyme_code,
                            :selector_nr      => design.selector_nr,
                            :roi_nr           => design.roi_nr,
                            :internal_QC      => design.internal_QC,
                            :annotation_codes => design.annotation_codes,
                            :other_annotations => design.other_annotations,
                            :sel_n_sites_start => design.sel_n_sites_start,
                            :sel_left_start_rel_pos => design.sel_left_start_rel_pos,
                            :sel_left_end_rel_pos   => design.sel_left_end_rel_pos,
                            :sel_left_site_used      => design.sel_left_site_used,
                            :sel_right_start_rel_pos => design.sel_right_start_rel_pos,
                            :sel_right_end_rel_pos   => design.sel_right_end_rel_pos,
                            :sel_right_site_used     => design.sel_right_site_used,
                            :sel_polarity            => design.sel_polarity,
                            :sel_5prime              => design.sel_5prime,
                            :sel_3prime              => design.sel_3prime,
                            :usel_5prime             => design.usel_5prime,
                            :usel_3prime             => design.usel_3prime,
                            :selector_useq           => design.selector_useq,
                            :amplicon_chr_start_pos  => design.amplicon_chr_start_pos,
                            :amplicon_chr_end_pos    => design.amplicon_chr_end_pos,
                            :amplicon_length         => design.amplicon_length,
                            :amplicon_seq            => design.amplicon_seq,
                            :version_id              => design.version_id,
                            :genome_build            => design.genome_build)
         if !@synth_oligo.save
           logger.error("Error saving oligo: #{@oligo_name}")
           return -6
        end
         
       end
     end
    
      rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to load synthesis for: #{@oligo_name} - oligo design not found")
        return -4
      rescue ActiveRecord::ActiveRecordError
        logger.error "Error loading oligo synthesis well for: #{@oligo_name}}"
        return -5
     end
   
   # drop through begin/end => transaction was successful, return 0
   return 0
   
  end #end of method

end
