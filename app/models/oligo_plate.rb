class OligoPlate < ActiveRecord::Base
  belongs_to :oligo_order, :foreign_key => "oligo_order_id"
  has_many :oligo_wells, :foreign_key => "oligo_plate_id"
  
  validates_uniqueness_of :oligo_plate_nr, :scope => :synth_plate_nr,
                          :on  => :create   
  
  def self.loadplates(synth_file, order_id)
    file_path = "#{RAILS_ROOT}/public#{synth_file}"
    plate_codes = ["S", "A", "B"]
    @save_cnt = @reject_cnt = 0
    
    # read first(index 0) and fourth (index 3) row of synthesis file
    synth_row = FasterCSV.read(file_path, {:col_sep => "\t"})[0]  
    submit_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3]
    
    # oligo plate number is first two substrings in row 1, col 1
    plate_dtl      = submit_row[0].split(/_/)  
    source_plate = [plate_dtl[0],plate_dtl[1]].join('_')
    
    # synthesis plate number is synthesis order nr (row 4, col 1) appended with plate# in parens
    synth_plate_nr = synth_row[0] + ' (' + plate_dtl[1] + ')' 
    
    # loop through plate codes, to create individual plates
    plate_codes.each do |copy_code|
      if copy_code == "S" 
        oligo_plate_nr = source_plate
      else
        oligo_plate_nr = source_plate + copy_code
      end       
    # if save fails, plate # is non-unique
    #    need to write to error log, and flag errors; continue loading other records?
      @oligo_plate = self.new(:oligo_plate_nr  => oligo_plate_nr,
                              :synth_plate_nr  => synth_plate_nr,
                              :plate_copy_code => copy_code,
                              :oligo_order_id  => order_id)                         
      if @oligo_plate.save
        @save_cnt += 1
      else
        @reject_cnt +=1
      end  
    end
    
    # set global variables to pass back to uploads controller
    $rec_loaded   = @save_cnt
    $rec_rejected = @reject_cnt
  end
  
end
