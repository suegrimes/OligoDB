class Aliquot < ActiveRecord::Base
  require 'fastercsv'
  
  belongs_to :oligo_plate, :foreign_key => "oligo_plate_id"
  belongs_to :pool_plate, :foreign_key => "pool_plate_id"
  
  def self.loadaliquots(plate_file)
    file_path = "#{RAILS_ROOT}/public#{plate_file}"
    @save_cnt = @reject_cnt = 0
    
    # read entire BioMec file into plate_well_dtls (2 dimensional array [row][col])
    @plate_well_dtls = FasterCSV.read(file_path, {:headers => true, :col_sep => "\t"})
    
    # loop through plate_well_dtls, and summarize by unique plate/well 
    # (assumes file is sorted by plate/well)
    @plate_well_dtls.each do |pw_row|
      source_plate_nr = pw_row[2]
      source_well_nr  = pw_row[3]
      dest_plate_nr   = pw_row[5]
      dest_well_nr    = pw_row[6]
      volume          = pw_row[7].to_f
      
      # create (dest) pool plate and/or well if it doesn't exist
      dest_plate = PoolPlate.find_or_create_by_pool_plate_nr(dest_plate_nr)
      dest_well  = PoolWell.find_or_create_by_pool_plate_id_and_pool_well_nr(dest_plate.id, dest_well_nr)
                       
      # find keys for (source) oligo plate and well
      source_plate = OligoPlate.find_by_oligo_plate_nr(source_plate_nr)
      source_well  = OligoWell.find_by_oligo_plate_id_and_oligo_well_nr(source_plate.id, source_well_nr)
      aliquot = Aliquot.new(
                       :oligo_well_id => source_well.id,
                       :pool_well_id  => dest_well.id,
                       :plate_from    => source_plate_nr,
                       :well_from     => source_well_nr,
                       :to_plate_or_pool => "O",
                       :plate_to      => dest_plate_nr,
                       :well_to       => dest_well_nr,
                       :volume_pipetted => volume)
      if aliquot.save
        @save_cnt += 1
      else
        @reject_cnt +=1
      end  
      
      # update well volumes in source and destination plates
      source_well.update_attributes(:well_rem_volume => source_well.well_rem_volume - volume) 
      #dest_well.update_attributes(:pool_volume => dest_well.pool_volume + volume)
      
    end
    
    # set global variables to pass back to uploads controller
    $rec_loaded   = @save_cnt
    $rec_rejected = @reject_cnt
  end
  
end
