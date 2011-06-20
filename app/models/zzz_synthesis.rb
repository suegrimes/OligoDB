class Synthesis < ActiveRecord::Base
  
  def self.save_synth_order(researcher, oligos)
    rownum = 0
    timestamp = Time.now
    @synthesis = Array.new
    @rec_loaded = @rec_rejected = 0
    
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
      if @synthesis[rownum-1].save
        then @rec_loaded += 1
        else @rec_rejected += 1
      end
    end
    
    # populate global variables with # records loaded and rejected
    $rec_loaded    = @rec_loaded
    $rec_rejected  = @rec_rejected
    
  end
  
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
            file_path = "#{RAILS_ROOT}/public/created_file/#{synth_file}.txt"
            f = File.new(file_path, 'w')
          else
            f.close
           
            @plate_nr = "%05d" % (@plate_nr.to_i + 1).to_s
            synth_file = date_ymd_ + @plate_nr + ("_") + researcher.researcher_initials
            file_path = "#{RAILS_ROOT}/public/created_file/#{synth_file}.txt"
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
          CreatedFile.create!(
                    :content_type => "Synthesis",
                    :created_file => synth_file,
                    :researcher_id => researcher.id)
                    
          # update last plate number used
          Indicator.update (1, :last_oligo_plate_nr => @plate_nr.to_i)
          #Indicator.update (1, :last_oligo_plate_nr => 21)
             
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
  
end
