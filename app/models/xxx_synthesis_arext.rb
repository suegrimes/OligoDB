class Synthesis < ActiveRecord::Base
  
  def self.save_synth_order(researcher, oligos)
    rownum = 0
    timestamp = Time.now
    @synthesis = Array.new
    
    # Use timestamp for created_at field, so that all records for this order can be grouped together
    for oligo in oligos do
      rownum += 1
      row = rownum.to_s
      
      #Populate synthesis array which will be loaded below with the ar-extensions import method
      @synthesis[rownum-1]= self.new(:researcher    => researcher, 
                            :order_line_nr => row,
                            :oligo_name    => oligo[:oligo_name], 
                            :gene_code     => oligo[:gene_code], 
                            :selector_useq => oligo[:selector_useq],
                            :created_at    => timestamp)
    end
    column_names = %W(researcher order_line_nr oligo_name gene_code selector_useq created_at)
    options = { :validate => true}
    
    loadresults = Synthesis.import( column_names, @synthesis, options)
    
    # populate global variables with # records loaded and rejected
    $rec_loaded    = loadresults.num_inserts
    $rec_rejected  = @synthesis.length - $rec_loaded
    
    # populate array with synthesis objects rejected in the import above
    # this array is not currently displayed; can be used for debugging
    @synthesis_rej = loadresults.failed_instances  
    
  end
  
  def self.create_synth_file(researcher, plate_start, nr_wells, oligos)
    file_path = "#{RAILS_ROOT}/public/created_file/synthesis.txt"
    f = File.new(file_path, 'w')
    
    #Write header
    #"SG" in synth_file is hardcoded, need to replace with researcher initials
    synth_file = Time.now.strftime("%y%m%d_") + plate_start + ("_SG")
    f.write "\tInstructions:" + 
                  "\t\"Fill in and Save As Text (tab delimited), then upload using web page\"\n\n"
    f.write "\tResearcher:\t" + researcher + "\n"
    f.write "\tDate:\t" + Time.now.strftime("%m/%d/%Y") + "\n"
    f.write "\tPlate ID:\t" + synth_file + "\n"
    f.write "\n\nNumber\tOligo Name\tSequence\n"
          
    #Write detail rows
    rownum = 0
    for oligo in oligos do
        # if current row number is zero, or a multiple of "nr_wells", start numbering at 1
        # otherwise, increment row number by 1.
        if rownum % nr_wells.to_i == 0
          rownum = 1
        else
          rownum += 1
        end
        
        row = rownum.to_s
        f.write row + "\t" + oligo[:oligo_name] + "\t" + oligo[:selector_useq] + "\n"
    end
    f.close
  end
  
end
