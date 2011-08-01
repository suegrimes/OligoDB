# == Schema Information
#
# Table name: aliquots
#
#  id               :integer(4)      not null, primary key
#  oligo_well_id    :integer(4)      default(0)
#  pool_well_id     :integer(4)      default(0)
#  plate_from       :string(50)
#  well_from        :string(4)
#  to_plate_or_pool :string(1)
#  plate_to         :string(50)
#  well_to          :string(4)
#  volume_pipetted  :decimal(11, 3)
#  created_at       :datetime
#  updated_at       :datetime
#

class Aliquot < InventoryDB
  
  belongs_to :oligo_well, :foreign_key => "oligo_well_id"
  belongs_to :pool_well, :foreign_key => "pool_well_id"
  
  #Set up header array - expected headers for file to be loaded from BioMek run
  BIOMEK_HEADERS = ['Oligo Name', 'Source Pos', 'Source Plate', 'Source Well',
                                  'Dest Pos', 'Dest Plate', 'Dest Well', 'Volume']
  
  def self.find_all_with_dtls(condition_array)
    self.find(:all, 
              :include => [{:oligo_well => :synth_oligo}, :pool_well],
              :conditions => condition_array)
  end
  
  ##############################################################################################
  # loadaliquots:                                                                              #
  # Method to load BioMek run into aliquots; updating volume in oligo_wells, and pool_wells    #
  ##############################################################################################
  
  def self.loadaliquots(file_path)
    #Initialize variables
    @save_cnt = @reject_cnt = 0
    $rec_loaded = $rec_rejected = 0
    
    # check for valid header record, with fields in correct order
    rc = self.check_biomek_hdr(file_path)
    return rc if rc < 0
    
    prev_source_plate_nr = 'none'
    prev_dest_plate_nr   = 'none' 
    prev_dest_well_nr    = 'xxx'
    
    begin
    # read entire BioMek file into plate_well_dtls (2 dimensional array [row][col])
    @plate_well_dtls = FasterCSV.read(file_path, {:headers => true, :col_sep => "\t"})
    
    # loop through plate_well_dtls, and summarize by unique plate/well 
    # (assumes file is sorted by plate/well)
    @plate_well_dtls.each do |pw_row|
      @source_plate_nr = pw_row[2]
      @source_well_nr  = pw_row[3]
      dest_plate_nr   = pw_row[5]
      dest_well_nr    = pw_row[6]
      @volume         = pw_row[7].to_f
      
      # break out of loop if blank line encountered - assume end of data
      break if (@source_plate_nr.blank? && @source_well_nr.blank?)
      
      # find id# key for (source) oligo plate; avoid SQL call if plate nr is same as previous
      @source_plate = OligoPlate.find_by_oligo_plate_nr(@source_plate_nr) unless @source_plate_nr == prev_source_plate_nr
      raise ActiveRecord::RecordNotFound if @source_plate.nil?
      
      @source_well  = OligoWell.find_by_oligo_plate_id_and_oligo_well_nr(@source_plate.id, @source_well_nr,
                                           :include => :synth_oligo)
      raise ActiveRecord::RecordNotFound if @source_well.nil?
      
      # create (dest) pool plate and/or well if necessary, otherwise increment volume
      @dest_plate = PoolPlate.find_or_create_by_pool_plate_nr(dest_plate_nr) unless dest_plate_nr == prev_dest_plate_nr 
      
      # update accumulated pool volume for previous plate/well, before accumulating new plate/well
      if dest_plate_nr != prev_dest_plate_nr || dest_well_nr != prev_dest_well_nr
        unless prev_dest_plate_nr == 'none'
           @dest_well.update_attributes(:pool_well_volume => @dest_well.pool_well_volume,
                                        :nr_oligos        => @dest_well.nr_oligos,
                                        :enzyme_code      => @dest_well.enzyme_code) 
        end
          # set up object to accumulate volumes for new destination plate/well
          @dest_well  = PoolWell.find_or_create_by_pool_plate_id_and_pool_well_nr(@dest_plate.id, dest_well_nr)
          @dest_well[:pool_plate_nr] = dest_plate_nr
          @dest_well[:enzyme_code] = @source_well.synth_oligo.enzyme_code.split(/_/)[0] 
          
          # Might need to default nr_oligos in table, to zero so that there is no 'nil' error.
          #@dest_well[:nr_oligos]   = 0  # should this be zero?, or if existing oligos in the well, need to use existing?
      end
      
      # adjust volume pipetted to ensure that source well does not drop below zero??  or fix after the fact?
      # if adjust here, it will be invisible to user, which might cause errors to continue
      
      # if @volume > @source_well.well_rem_volume
      # then @adj_volume = @source_well.well_rem_volume
      # else @adj_volume = @volume
      # end 
      
      aliquot = Aliquot.new(
                       :oligo_well_id => @source_well.id,
                       :pool_well_id  => @dest_well.id,
                       :plate_from    => @source_plate_nr,
                       :well_from     => @source_well_nr,
                       :to_plate_or_pool => "O",
                       :plate_to      => dest_plate_nr,
                       :well_to       => dest_well_nr,
                       :volume_pipetted => @volume)
      if aliquot.save
        @dest_well[:pool_well_volume] += @volume
        @dest_well[:nr_oligos]        += 1
        @source_well.update_attributes(:well_rem_volume => @source_well.well_rem_volume - @volume) 
        @save_cnt += 1
      else
        logger.error("Unable to save aliquot from: #{@source_plate_nr} #{@source_well_nr}" +
                                              " to: #{dest_plate_nr} #{dest_well_nr}")
        @reject_cnt +=1
      end      
      
      # populate "previous" plate and well variables for next iteration of loop
      prev_dest_plate_nr   = dest_plate_nr
      prev_dest_well_nr    = dest_well_nr
      prev_source_plate_nr = @source_plate_nr                 
    end
    
    rescue FasterCSV::MalformedCSVError
      logger.error("File: #{file_path} is not in CSV format")
      return -2
      
    rescue ActiveRecord::RecordNotFound
      logger.error("Plate or well not found for: #{@source_plate_nr}, well: #{@source_well_nr}")
      $rec_loaded = @save_cnt
      return -4
      
    rescue ActiveRecord::ActiveRecordError
      logger.error("Error updating from: #{@source_plate_nr}, well: #{@source_well_nr}")
      $rec_loaded = @save_cnt
      return -5
      
    end  
    
    # update destination well volume for final destination well instance
    @dest_well.update_attributes(:pool_well_volume => @dest_well.pool_well_volume,
                                 :nr_oligos   => @dest_well.nr_oligos,
                                 :enzyme_code => @dest_well.enzyme_code)
    
    # set global variables to pass back to uploads controller
    $rec_loaded   = @save_cnt
    $rec_rejected = @reject_cnt
    return 0
    
  end
  
private
  def self.check_biomek_hdr(file_path)
    input_hdr = FasterCSV.read(file_path, {:headers => false, :col_sep => "\t"})[0]
    
    BIOMEK_HEADERS.each_with_index do |col_hdr, index|
      if input_hdr[index].strip != col_hdr
        logger.error("Column #{index} mismatch.  File hdr: #{input_hdr[index]}, expected hdr: #{col_hdr}")
        return -6 
      end
    end
    return 0
  end
  
end
