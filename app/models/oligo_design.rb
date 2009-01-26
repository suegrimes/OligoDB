class OligoDesign < ActiveRecord::Base
  require 'fastercsv'
  
  belongs_to :region, :foreign_key => "region_id"
  has_many :oligo_wells, :foreign_key => "oligo_design_id"
  
  validates_uniqueness_of :oligo_name,
                          :on  => :create                      
  
  def self.unique_genes
    find(:all, :select => "gene_code", :group => :gene_code)
  end
  
  def self.unique_enzymes
    find(:all, :select => "enzyme_code", :group => :enzyme_code)
  end
  
  def self.loaddesigns(design_file)
   file_path = "#{RAILS_ROOT}/public#{design_file}"
   
   #initialize save and reject counters
   @save_cnt = 0
   @reject_cnt = 0
   
   FasterCSV.foreach(file_path, {:headers => :first_row, :col_sep => "\t"}) do |row|
     #create oligo array, splitting oligo name fields by '_'
     oligo = row[18].split(/_/) 
   
     #find region id for this gene and roi number
     @region = Region.find(:first, :conditions => 
                           ["gene_code = ? AND roi_nr = ?", oligo[0], oligo[-1]])
   
     #convert chromosome start position to integer
     chr_start = row[3].to_i
   
     #create new oligo_design record
     oligo_design = self.new(
       :oligo_name => [row[0], row[13], row[18]].join('_'),
       :gene_code => oligo[0],
       :enzyme_code => row[13],
       :selector_nr => row[0],
       :region_id => @region.id,
       :roi_nr => oligo[-1],
       :sel_n_sites_start => row[9],
       :sel_left_start_rel_pos => row[4],
       :sel_left_end_rel_pos => row[5],
       :sel_left_site_used => row[10],
       :sel_right_start_rel_pos => row[6],
       :sel_right_end_rel_pos => row[7],
       :sel_right_site_used => row[11],
       :sel_polarity => row[12],
       :sel_5prime => row[15],
       :sel_3prime => row[16],
       :usel_5prime => row[19][0,20],  #first 20 chars of sequence
       :usel_3prime => row[19][60,20], #chars 61-80 of sequence
       :selector_useq => row[19],
       :amplicon_length => row[8],
       :amplicon_chr_start_pos => chr_start + row[4].to_i,
       :amplicon_chr_end_pos => (chr_start + row[4].to_i + row[8].to_i - 1),
       :amplicon_seq => row[17]
       )
     if oligo_design.save
       @save_cnt += 1
     else
       @reject_cnt +=1
     end  
     
   end  #end of fastercsv read loop
   
   #populate global variables to pass to uploads controller
   $rec_loaded   = @save_cnt
   $rec_rejected = @reject_cnt
   
 end
end
