# == Schema Information
#
# Table name: oligo_wells
#
#  id                    :integer(4)      not null, primary key
#  oligo_plate_nr        :string(50)      default(""), not null
#  oligo_well_nr         :string(4)       default(""), not null
#  oligo_plate_id        :integer(4)      default(0), not null
#  oligo_plate_num       :string(8)
#  plate_copy_code       :string(2)
#  oligo_design_id       :integer(4)
#  synth_oligo_id        :integer(4)      not null
#  oligo_name            :string(100)
#  enzyme_code           :string(20)
#  well_initial_volume   :decimal(11, 3)
#  well_rem_volume       :decimal(11, 3)
#  well_suspend_lysophil :string(1)
#  created_at            :datetime
#  updated_at            :datetime
#

class OligoWell < InventoryDB
  
  belongs_to :synth_oligo, :foreign_key => "synth_oligo_id"
  belongs_to :oligo_plate, :foreign_key => "oligo_plate_id"
  
  has_many :aliquots, :foreign_key => "oligo_well_id"
  
  validates_uniqueness_of :oligo_well_nr, :scope => "oligo_plate_nr", :on => :create
  
  BUFFER_VOL = 5   # Excess volume to exist in well being pipetted from (ie. cannot pipette down to 0 vol)
  COPY_CODES_NOT_FOR_POOL = ['A', 'B', 'S']
  COPY_CODES_FOR_POOL = ['C', 'D']
  MAX_SOURCE_PLATES_FOR_BIOMEK = 8
  MAX_OLIGOS_FOR_BIOMEK = 192
  
  ###############################################################################################
  # loadwells:                                                                                  #
  # Method to load synthesized oligos (from file), into oligo_plates, oligo_wells               #
  ###############################################################################################
  def self.loadwells(file_path)
    @save_cnt = @reject_cnt = 0
    $rec_loaded = $rec_rejected = 0
    
    #Read row 4 (array index=3) of synthesis file, which contains submitted plate nr
    submit_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3] 
    
    #split 1st column, with _ delimiter to determine plate number
    plate_dtl     = submit_row[0].split(/_/)  
    plate_num     = plate_dtl[1]
    source_plate  = [plate_dtl[0],plate_dtl[1]].join('_')
    logger.info("****LOADING PLATE: #{source_plate} ****")
    
    plate_ids = {}
    begin
      OligoPlate::SYNTHESIS_COPY_CODES.each do |copy_code|
        plate_nr  = source_plate
        plate_nr += copy_code if copy_code != 'S'
        
        oligo_plate = OligoPlate.find_by_oligo_plate_nr(plate_nr)
        raise ActiveRecord::RecordNotFound if oligo_plate.nil? 
        plate_ids[copy_code] = oligo_plate.id
      end
    
    rescue ActiveRecord::ActiveRecordError
      logger.error("Plate: #{source_plate}, copy: #{copy_code} not found")
      return -4
    end
    
    #read rows 9 (array index=8) to eof, which contain details of oligo synthesis
    well_dtls = FasterCSV.read(file_path, {:col_sep => "\t"})[8..-1]
    
    #loop through well_dtls array and create details for master plate, copy plate A, copy plate B
    begin 
    well_dtls.each do |well_row|
      
      if (well_row[2].nil? || well_row[2].empty? || well_row[2].length < 6)
        logger.info "Premature end of file at plate: #{plate_num}, row: #{well_row[1]}"
        eof_reached = true
       else
         @oligo_name    = well_row[2]
         synth_oligo    = SynthOligo.find_using_oligo_name(@oligo_name)
       end
       
       break if eof_reached
       
      raise ActiveRecord::RecordNotFound  if synth_oligo.nil?
        
      synth_oligo_id = synth_oligo.id  
      oligo_well_nr = well_row[1]
      
      OligoPlate::SYNTHESIS_COPY_CODES.each do |copy_code|
        plate_nr = (copy_code == 'S'? source_plate : source_plate + copy_code)
        plate_id = plate_ids[copy_code]
        
        case copy_code
          when "S"
          well_initial_volume = well_row[3]
          well_rem_volume     = well_row[6]
          
          when "A"
          well_initial_volume = well_row[4]
          well_rem_volume     = well_row[4]
          
          when "B"
          well_initial_volume = well_row[5] 
          well_rem_volume     = well_row[5]
        end  #end case
      
        @oligo_well = self.new(:oligo_plate_id      => plate_id,
                               :oligo_plate_nr      => plate_nr,
                               :oligo_plate_num     => plate_num,
                               :plate_copy_code     => copy_code,
                               :oligo_name          => @oligo_name,
                               :enzyme_code         => synth_oligo.enzyme_code,
                               :synth_oligo_id      => synth_oligo_id,
                               :oligo_well_nr       => oligo_well_nr,
                               :well_initial_volume => well_initial_volume,
                               :well_rem_volume     => well_rem_volume)
        
          if @oligo_well.save
            @save_cnt += 1
          else
            logger.error("Unable to save: #{plate_nr} #{oligo_well_nr}, #{@oligo_name}")
            logger.error("ids are:  oligo well #{@oligo_well.id}, plate #{@oligo_well.oligo_plate_id}, oligo #{synth_oligo_id}")
            @reject_cnt +=1
          end 
        
        end #end plate copy do statement   
      end # end well details each statement
      
      rescue FasterCSV::MalformedCSVError
        logger.error "File: #{file_path} is not in CSV format"
        return -2
      rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to load oligo synthesis well for: #{@oligo_name} - oligo not found")
        return -4
      rescue ActiveRecord::ActiveRecordError
        logger.error "Error loading oligo synthesis well for: #{@oligo_name}}"
        return -5
      end  #transaction block
    
    # set global variables to pass back to uploads controller
    $rec_loaded   = @save_cnt
    $rec_rejected = @reject_cnt
    return 0
    
  end  
 
  ###############################################################################################
  # create_copy_wells:                                                                          #
  # Method to populate wells of copy plates, from copy volume given, plus info in source plate  #   
  ###############################################################################################
  def self.create_copy_wells(copy_plates, source_plate_id)
    begin
      source_wells = OligoWell.find_all_by_oligo_plate_id(source_plate_id)
      raise ActiveRecord::RecordNotFound  if source_wells.nil?
      
      copy_plates.each do |cplate|
        copy_plate = OligoPlate.find_by_oligo_plate_nr(cplate['oligo_plate_nr'])
        raise ActiveRecord::RecordNotFound  if copy_plate.nil?
        
        source_wells.each do |sourcewell|
          @oligo_well = self.new(:oligo_plate_nr  => copy_plate.oligo_plate_nr,
                                 :oligo_well_nr   => sourcewell.oligo_well_nr,
                                 :oligo_plate_id  => copy_plate.id,
                                 :oligo_plate_num => copy_plate.oligo_plate_num,
                                 :plate_copy_code => copy_plate.plate_copy_code,
                                 :oligo_design_id => sourcewell.oligo_design_id,
                                 :synth_oligo_id  => sourcewell.synth_oligo_id,
                                 :oligo_name      => sourcewell.oligo_name,
                                 :enzyme_code     => sourcewell.enzyme_code,
                                 :well_initial_volume => cplate['volume'],
                                 :well_rem_volume => cplate['volume'])
          
           if !@oligo_well.save
             logger.error("Error saving copy plate: #{@oligo_well.oligo_plate_nr}, well: #{@oligo_well.oligo_well_nr}")
             return -6
           end
          end  # end source_wells do
        end    # end copy_wells do
      
        rescue ActiveRecord::RecordNotFound
          logger.error("Error, source plate: #{source_plate}, or associated copy plate not found")
          return -4
        rescue ActiveRecord::ActiveRecordError
          logger.error("Error creating copy plate: #{@oligo_well.oligo_plate_nr}, well: #{@oligo_well.oligo_well_nr}")
          return -5     
    end # end transaction
    
    # drop through begin/end => transaction was successful, return 0
    return 0
  end
  
  ###############################################################################################
  # decrement_wells:                                                                            #
  # Method to decrement source_plate wells, after creating copy plates                          #   
  ###############################################################################################
  def self.decrement_wells(plate_id, decrement_vol)
    self.update_all("well_rem_volume = well_rem_volume - #{decrement_vol}", ["oligo_plate_id = ?", plate_id])
  end
  
  ###############################################################################################
  # find_wells_with_low_volume:                                                                 #
  # Method to find plate/wells with less than a specified well volume                           #
  ###############################################################################################
  def self.find_wells_with_low_volume(vol)
    
    self.find(:all, :conditions => ["well_rem_volume < ?", vol],
                    :order => "oligo_plate_num, oligo_well_nr, well_rem_volume")
  end
  
  ###############################################################################################
  # find_wells_for_biomek_run:                                                                  #
  # Method to find plate/wells with sufficient volume for pipetting to pools                    #
  ###############################################################################################
  def self.find_wells_for_biomek_run(synth_oligos, vol)
    synth_ids = synth_oligos.map { |syn| syn.id }

    ids_and_plates = SynthOligo.find(:all,
                                     :select => "synth_oligos.id, 
                                                 MIN(CONCAT(oligo_wells.oligo_plate_num, oligo_wells.plate_copy_code)) AS 'working_plate'",
                                     :joins => :oligo_plates,  
                                     :conditions => ["synth_oligos.id IN (?) AND oligo_wells.well_rem_volume > ?
                                                      AND oligo_plates.plate_copy_code NOT IN (?)
                                                      AND oligo_plates.plate_depleted_flag = 'N' 
                                                      AND oligo_plates.available_for_pool = 'Y'",
                                                      synth_ids, vol, COPY_CODES_NOT_FOR_POOL],
                                     :group => "synth_oligos.id",
                                     :order => "synth_oligos.id, oligo_wells.oligo_plate_nr")     

    idplate_concat = ids_and_plates.map {|id_plate| [id_plate.id, id_plate.working_plate].join}
                                              
    plate_wells    = OligoWell.find(:all,
                                    :conditions => ["oligo_wells.synth_oligo_id IN (?) AND
                                                    CONCAT(CAST(synth_oligo_id AS CHAR), oligo_plate_num, plate_copy_code) IN (?)",
                                                    synth_ids, idplate_concat],
                                    :group => "oligo_wells.synth_oligo_id")
    #return plate_wells
    return plate_wells.sort_by {|well| [well.oligo_plate_nr, well.id]}
      
  end
  
  ###############################################################################################
  # create_biomek_order:                                                                        #
  # Method to create template for biomek run                                                    #
  ###############################################################################################
  def self.create_biomek_order(oligowells, dest_params, researcher_id)
    pool_plate_num = "%05d" % (Indicator.find_and_increment_pool_plate).to_s
    pool_plate_nr  = [dest_params[:plate], pool_plate_num].join("_")
   
    file_name = pool_plate_nr
    file_path = File.join(CreatedFile::FILES_ROOT, "#{file_name}.txt")
    f = File.new(file_path, 'w')
    
    #write header record
    f.write   "Oligo Name \t" + 
              "Source Pos \t" +
              "Source Plate \t" +
              "Source Well \t" +
              "Dest Pos \t" +
              "Dest Plate \t" +
              "Dest Well \t" +
              "Volume \n"
              
    last_oligo_plate = ''
    pos_cnt = 0
    oligo_cnt = 0
    
    oligowells.each do |plate_well|
      oligo_cnt += 1
      pos_cnt += 1  if plate_well[:oligo_plate_nr] != last_oligo_plate
      last_oligo_plate = plate_well[:oligo_plate_nr]
      
      #reset plate position count, and get next sequential pool plate number, if 
      # more than maximum number of source plates/biomek run is encountered
      # or if more than the maximum number of oligos per biomek run is encountered
      if pos_cnt == MAX_SOURCE_PLATES_FOR_BIOMEK + 1 || oligo_cnt == dest_params[:max_oligos].to_i + 1
        oligo_cnt = 1
        pos_cnt = 1
        pool_plate_num = "%05d" % (Indicator.find_and_increment_pool_plate).to_s
        pool_plate_nr  = [dest_params[:plate], pool_plate_num].join("_")
      end
      
      f.write   plate_well[:oligo_name]     + "\t" +
                "P" + pos_cnt.to_s          + "\t" + 
                plate_well[:oligo_plate_nr] + "\t" + 
                plate_well[:oligo_well_nr]  + "\t" +
                dest_params[:pos]           + "\t" +
                pool_plate_nr               + "\t" +
                plate_well[:dest_well]      + "\t" +
                plate_well[:volume]         + "\n"
    end
    
    # write file name to CreatedFile model
    CreatedFile.create!(
              :content_type => "BioMek",
              :created_file => file_name,
              :researcher_id => researcher_id)
    
    f.close  
  end

  ###############################################################################################
  # oligo_platenum:                                                                             #
  # Method to determine numeric plate number (strip "plate_" prefix, and alphabetic suffix)     #
  #    **NOT USED?**                                                                            #
  ###############################################################################################
#  def oligo_platenum
#    temp_plate       = oligo_plate_nr.split(/_/)   
#    # split plate number (string following _) into individual characters
#    temp_plate_chars = temp_plate[1].split('')
#    # if last character of plate number is alphabetic, strip last character
#    return (temp_plate_chars[-1] =~ /[A-Z]|[a-z]/? temp_plate_chars[0..-2] : temp_plate[1])
#  end
  
  ###############################################################################################
  # oligo_platecopy:                                                                            #
  # Method to determine copy code for oligo_plate.  Use last char if alphabetic, else 'S'       #
  #    **NOT USED?**                                                                            #
  ###############################################################################################
#  def oligo_platecopy
#    temp_plate       = oligo_plate_nr.split(/_/)
#    # split plate number (string following _) into individual characters
#    temp_plate_chars = temp_plate[1].split('') 
#    # if last character of plate number is alphabetic, return it, otherwise return 'S'
#    return (temp_plate_chars[-1] =~ /\d/? 'S' : temp_plate_chars[-1])
#  end

  ###############################################################################################
  # unique_plates_and_min_vol:                                                                  #
  # Method to find minimum remaining well volume by plate number                                #
  #    **NOT USED?**                                                                            #
  ###############################################################################################
#  def self.unique_plates_and_min_vol
#    self.find(:all, :select => "oligo_plate_nr, min(well_rem_volume) as min_volume", 
#    :group => :oligo_plate_nr)
#  end

  ###############################################################################################
  # find_assoc_plates_for_wells:                                                                #
  # Method to find oligo plates for given wells.  Not used??                                    #
  ###############################################################################################
#  def self.find_assoc_plates_for_wells(wells)
#    
#    @platewells = Array.new 
#    for well in wells do
#      @pwell = well.oligo_plate_num + "-" + well.oligo_well_nr
#      @platewells.push(@pwell)
#    end
#    
#    self.find(:all, 
#              :conditions => ["concat(oligo_plate_num, '-', oligo_well_nr) IN (?)",
#                             @platewells],
#              :order => "oligo_plate_num, oligo_well_nr, well_rem_volume")
#   
#  end
end
