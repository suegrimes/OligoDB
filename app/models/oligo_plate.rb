class OligoPlate < ActiveRecord::Base
  belongs_to :oligo_order, :foreign_key => "oligo_order_id"
  has_many :oligo_wells, :foreign_key => "oligo_plate_id"
  
  validates_uniqueness_of :oligo_plate_nr, :synth_plate_nr,
                          :on  => :create   
  
  def self.loadplates(synth_file)
    file_path = "#{RAILS_ROOT}/public#{synth_file}"
    
    # read first(index 0) and fourth (index 3) row of synthesis file
    synth_row = FasterCSV.read(file_path, {:col_sep => "\t"})[0]  
    submit_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3]
    
    # submitted plate number is first two substrings in row 1, col 1
    plate_dtl   = submit_row[0].split(/_/)  
    oligo_plate_nr = [plate_dtl[0],plate_dtl[1]].join('_')
    
    # synthesis plate number is synthesis order nr (row 4, col 1) appended with plate# in parens
    synth_plate_nr = synth_row[0] + ' (' + plate_dtl[1] + ')' 
    
    # save master plate, copy plate A, copy plate B
    # order id defaulting to 1 (dummy order); need to fix, or del oligo_order table if not needed
    self.savenew(oligo_plate_nr, synth_plate_nr, 'S', 1)
    self.savenew(oligo_plate_nr + 'A', synth_plate_nr, 'A', 1)
    self.savenew(oligo_plate_nr + 'B', synth_plate_nr, 'B', 1)
   end
 
  def self.savenew(oligo_plate_nr, synth_plate_nr, copy_code, order_id)
    # need to add check for uniqueness of plate_nr
    # if non-unique, write to error log, and flag errors; continue loading other records?
    @oligo_plate = self.new(:oligo_plate_nr => oligo_plate_nr,
                            :synth_plate_nr => synth_plate_nr,
                            :plate_copy_code => copy_code,
                            :oligo_order_id => order_id)
    @oligo_plate.save
  end
  
end
