# == Schema Information
#
# Table name: oligo_plates
#
#  id                  :integer(11)     not null, primary key
#  oligo_order_id      :integer(11)
#  oligo_plate_nr      :string(50)      default(""), not null
#  oligo_plate_num     :string(8)
#  synth_plate_nr      :string(25)
#  plate_copy_code     :string(2)       default(""), not null
#  oligo_conc_um       :integer(8)
#  te_concentration    :decimal(11, 4)
#  storage_location_id :integer(11)
#  plate_depleted_flag :string(1)
#  available_for_pool  :string(1)
#  comments            :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class OligoPlate < InventoryDB
  
  belongs_to :oligo_order,      :foreign_key => :oligo_order_id
  belongs_to :storage_location, :foreign_key => :storage_location_id
  has_many :oligo_wells,        :foreign_key => :oligo_plate_id
  
  validates_uniqueness_of :oligo_plate_nr, :scope => :synth_plate_nr,
                          :on  => :create 
                          
  named_scope :ok4pool, :conditions => ["plate_depleted_flag = 'N' AND available_for_pool = 'Y'"]
  
  SYNTHESIS_COPY_CODES = ['S']
  SOURCE_FOR_COPY = ['A','B', 'S']
  TE_TB = ['TE', 'TB', 'TB(Tris)']
  OLIGO_UM = [10, 100]
  
  def before_create
    self.storage_location_id = (plate_copy_code[0,1] == 'C' ? 2 : 1)
  end
                          
  ###############################################################################################
  # find_sorted_with_loc:                                                                       #
  # Method to find all plates, sort by numeric plate number, and include location               #
  ###############################################################################################
  def self.find_sorted_with_loc(platenum=nil)
    if platenum.nil?
      condition_array = []
    elsif platenum.to_i == 0  # plate number is zero, or not numeric
      return nil
    else
      condition_array = ["CAST(oligo_plate_num AS UNSIGNED) = ?", platenum.to_i]
    end
    
    self.find(:all, :include => :storage_location,
                    :conditions => condition_array,
                    :order => 'CAST(oligo_plate_num AS UNSIGNED) DESC, oligo_plate_nr')
  end
  
  ###############################################################################################
  # find_max_copy_num:                                                                          #
  # Method to find highest numeric copy num, for specified plate and copy code                  #
  ###############################################################################################
  def self.find_max_copy_num(base_plate, copy_code)
    #base_plate is of the form:  'plate_nnnnXn', or 'yymmddx_nnnnXn'
    #    where X is an optional copy code, and n is an optional copy digit.
    copy_plate     = [base_plate, copy_code].join
    oligo_plate = self.find(:first, :conditions => ["oligo_plate_nr LIKE ?", [copy_plate,'%'].join],
                                    :order => 'oligo_plate_nr DESC')
    if oligo_plate.nil?
      max_copy = 0
    elsif oligo_plate.oligo_plate_nr.length == copy_plate.length   # no digits after copy code
      max_copy = 0
    else
      # number of digits after alpha copy code will be length of plate# including digits minus length excluding digits
      max_copy = (oligo_plate.oligo_plate_nr[copy_plate.length, (oligo_plate.oligo_plate_nr.length - copy_plate.length)]).to_i
    end
    return max_copy
  end
  
  ###############################################################################################
  # loadplates:                                                                                 #
  # Method to create new oligo_plates records, from synthesis order (file)                      #
  ###############################################################################################
  def self.loadplates(file_path, order_id)
    @save_cnt = @reject_cnt = 0
    $rec_loaded = $rec_rejected = 0
    
    # read first(index 0) and fourth (index 3) row of synthesis file
    begin
    synth_row  = FasterCSV.read(file_path, {:col_sep => "\t"})[0]
    conc_row   = FasterCSV.read(file_path, {:col_sep => "\t"})[1]
    submit_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3]
    
    # oligo plate number is first two substrings in row 1, col 1
    plate_dtl      = submit_row[0].split(/_/)  
    source_plate = [plate_dtl[0],plate_dtl[1]].join('_')
    
    # oligo concentration is in format: '100 uM' in row 2, col 1
    concentration = conc_row[0].strip.gsub(/uM$/, '').strip
    
    # synthesis plate number is synthesis order nr (row 4, col 1) appended with plate# in parens
    synth_plate_nr = synth_row[0] + '_' + plate_dtl[1] 
    plate_num = plate_dtl[1]
    
    # loop through plate codes, to create individual plates
    SYNTHESIS_COPY_CODES.each do |copy_code|
      oligo_plate_nr = (copy_code == 'S'? source_plate : source_plate + copy_code)
      
    # if save fails, plate # is non-unique   
      @oligo_plate = self.new(:oligo_plate_nr      => oligo_plate_nr,
                              :oligo_plate_num     => plate_num,
                              :synth_plate_nr      => synth_plate_nr,
                              :plate_copy_code     => copy_code,
                              :oligo_conc_um       => concentration,
                              :oligo_order_id      => order_id,
                              :plate_depleted_flag => 'N',
                              :available_for_pool  => 'Y')                         
      if @oligo_plate.save
        @save_cnt += 1
      else
        logger.error("Unable to save plate: #{oligo_plate_nr}")
        @reject_cnt +=1
      end  
    end
    
    rescue FasterCSV::MalformedCSVError
      logger.error "File: #{file_path} is not in CSV format"
      return -2
    rescue ActiveRecord::ActiveRecordError
      logger.error "Unknown error: #{source_plate}"
      return -5
    end #end of transaction
    
    # set global variables to pass back to uploads controller
    $rec_loaded   = @save_cnt
    $rec_rejected = @reject_cnt
    return 0
  end
  
  ###############################################################################################
  # create_copy_plates:                                                                         #
  # Method to create new daughter plates, from existing oligo_plates                            #
  ###############################################################################################
  def self.create_copy_plates(copy_plates, source_plate_id)
    begin
      oligo_plate = self.find_by_id(source_plate_id)
      raise ActiveRecord::RecordNotFound  if oligo_plate.nil?
      
      copy_plates.each do |plate|
      
      @oligo_plate = self.new(:oligo_plate_nr  => plate['oligo_plate_nr'],
                              :oligo_plate_num => plate['oligo_plate_num'],
                              :plate_copy_code => plate['plate_copy_code'],
                              :synth_plate_nr  => oligo_plate.oligo_plate_nr,
                              :oligo_conc_um   => plate['oligo_conc_um'],
                              :te_concentration => plate['te_concentration'],
                              :plate_depleted_flag => 'N',
                              :available_for_pool => 'Y')
      if !@oligo_plate.save
           logger.error("Error saving copy plate: #{plate['oligo_plate_nr']}")
           return -6
           end
       
      
      end
      rescue ActiveRecord::RecordNotFound
        logger.error("Error, source plate: #{source_plate} not found")
        return -4
      rescue ActiveRecord::ActiveRecordError
        logger.error("Error creating copy plate: #{@oligo_plate.oligo_plate_nr}")
        return -5     
    end
    
    # drop through begin/end => transaction was successful, return 0
    return 0
  end
   
  
end #end of class
