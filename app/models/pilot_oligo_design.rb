# == Schema Information
#
# Table name: pilot_oligo_designs
#
#  id                      :integer(4)      not null, primary key
#  oligo_name              :string(100)     default(""), not null
#  target_region_id        :integer(4)      default(0)
#  valid_oligo             :string(1)
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

class PilotOligoDesign < OligoDesign
  set_table_name 'pilot_oligo_designs'
  
  require 'ar-extensions/adapters/mysql'
  require 'ar-extensions/import/mysql'
  
  def self.loaddesigns(file_path, version_id=5)
   #initialization
   pilot_oligo_designs = Array.new
   @version      = Version.find_by_id(version_id)
   
   # alter pilot_oligo_designs table to set next autoincrement id, to the same number as oligo_designs table
   # this ensures unique id numbers across both tables
   oligo_next_id = next_autoincr('oligo_designs').to_i
   pilot_next_id = next_autoincr('pilot_oligo_designs').to_i
   if pilot_next_id < oligo_next_id
     id_num  = set_autoincr('pilot_oligo_designs', oligo_next_id).to_i 
   else
     id_num  = pilot_next_id
   end
   
   i = 0
   FasterCSV.foreach(file_path, {:headers => :first_row, :col_sep => "\t"}) do |row|
     
     gene_roi       = row[18].split(/_/)    # split composite gene_roi field by '_'
     amplicon_start = row[3].to_i + row[4].to_i - 1  # chr_target_start + l_sel_start -1
     oligo_name     = [id_num.to_s, row[2], amplicon_start.to_s, row[8], row[18], row[13]].join('_')
   
     #create new oligo_design record
     pilot_oligo_designs[i] = self.new(
       :oligo_name              => oligo_name,
       :chromosome_nr           => row[2],
       :gene_code               => gene_roi[0],
       :enzyme_code             => row[13],
       :selector_nr             => 0,
       :roi_nr                  => gene_roi[-1],
       :sel_n_sites_start       => row[9].to_i,
       :sel_left_start_rel_pos  => row[4.to_i],
       :sel_left_end_rel_pos    => row[5].to_i,
       :sel_left_site_used      => row[10].to_i,
       :sel_right_start_rel_pos => row[6].to_i,
       :sel_right_end_rel_pos   => row[7].to_i,
       :sel_right_site_used     => row[11].to_i,
       :sel_polarity            => row[12][0,1],
       :sel_5prime              => row[15],
       :sel_3prime              => row[16],
       :usel_5prime             => row[19][0,20],  #first 20 chars of sequence
       :usel_3prime             => row[19][60,20], #chars 61-80 of sequence
       :selector_useq           => row[19],
       :amplicon_length         => row[8].to_i,
       :amplicon_chr_start_pos  => amplicon_start,
       :amplicon_chr_end_pos    => amplicon_start + row[8].to_i - 1, #amplicon_start + amplicon_length -1
       :amplicon_seq            => row[17],
       :version_id              => @version.id,
       :genome_build            => @version.genome_build
       )
     i      += 1  #increment array index 
     id_num += 1  #increment sequential id (primary key in table, used as part of oligo_name)
     
   end  #end of fastercsv read loop
   
   column_names = %W(oligo_name chromosome_nr gene_code enzyme_code selector_nr roi_nr
                     sel_n_sites_start sel_left_start_rel_pos sel_left_end_rel_pos
                     sel_left_site_used sel_right_start_rel_pos sel_right_end_rel_pos
                     sel_right_site_used sel_polarity sel_5prime sel_3prime
                     usel_5prime usel_3prime selector_useq amplicon_length
                     amplicon_chr_start_pos amplicon_chr_end_pos amplicon_seq
                     version_id genome_build)
   options = { :validate => false}
    
   pilot_oligo_designs_loaded = PilotOligoDesign.import( column_names, pilot_oligo_designs, options)
   
   # populate array with oligodesign objects rejected in the import above
   # this array is not currently displayed; can be used for debugging
   @oligodesign_rej = pilot_oligo_designs_loaded.failed_instances
   
   #populate global variables to pass to uploads controller
   $rec_rejected    = @oligodesign_rej.length
   $rec_loaded      = pilot_oligo_designs.length - $rec_rejected
   
   # alter oligo_designs table to set next autoincrement id, to the same number as pilot_oligo_designs table
   # this ensures that id numbers just created for pilot_oligo_designs, are not reused in oligo_designs
   # run in the background by using the 'sched' parameter, since update to large table causes browser time-out, and it is
   # not necessary to have the updated autoincrement id returned.
   set_autoincr('oligo_designs', 'pilot_oligo_designs', 'sched')
   rc = ($rec_loaded > 0 ? 0 : -6)
   return rc
  end
 
end
