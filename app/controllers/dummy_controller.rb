class DummyController < ApplicationController
  
  def notimplemented
  end

  def debug
  end
  
  def test
    @plate_ids = {}
    begin
      OligoPlate::SYNTHESIS_COPY_CODES.each do |copy_code|
        plate_nr  = 'plate_0003'
        plate_nr += copy_code if copy_code != 'S'
        
        oligo_plate = OligoPlate.find_by_oligo_plate_nr(plate_nr)
        raise ActiveRecord::RecordNotFound if oligo_plate.nil? 
        @plate_ids[copy_code] = oligo_plate.id
      end
    
    rescue ActiveRecord::ActiveRecordError
      logger.error("Plate: #{source_plate}, copy: #{copy_code} not found")
      return -4
    end
    
    render :action => 'debug'
  end
  
  def test1
    @oligo_list = ['1_MseI_AKT1_ROI_11',
                   '1_BfaI_gapfill_AKT1_ROI_7',
                   '2_15_123456_123_AKT1_xyz_ROI_11_MseI',
                   '3_15_345678_334_AKT1_abc_def_ROI_15_MseI_backfill', 
                   '613157_8_113306125_612_CSMD3_ROI_72_BfaI']
    indx = 4
    
    oligo_name = @oligo_list[indx]
    curr_format = curr_oligo_format?(oligo_name)
    
    if indx == 4 || indx == 0
      oligo_design = OligoDesign.find_using_oligo_name_id1(oligo_name)
      if oligo_design.nil?
        render :text => "Oligo design name: #{oligo_name}, not found"
      else
        #oligo_design = SynthOligo.find_using_oligo_name(oligo_name)
        render :text => "Oligo design name is: #{oligo_design.oligo_name}, id is: #{oligo_design.id}"
      end
    else
      render :text => "Oligo name is: #{oligo_name}, Curr format?: #{curr_format}"
    end
  end
  
  def test2
    @oligo_list = ['1_MseI_AKT1_ROI_11',
                   '1_BfaI_gapfill_AKT1_ROI_7',
                   '2_15_123456_123_AKT1_xyz_ROI_11_MseI',
                   '3_15_345678_334_AKT1_abc_def_ROI_15_MseI_backfill', 
                   '613157_8_113306125_612_CSMD3_ROI_72_BfaI']
    indx = 0
    
    oligo_name = @oligo_list[indx]
    gene_code  = get_gene_from_oligo_name(oligo_name)
    curr_format = curr_oligo_format?(oligo_name)
    
    if indx == 4 || indx == 0
      oligo_design = OligoDesign.find_using_oligo_name_id1(oligo_name)
      #oligo_design = SynthOligo.find_using_oligo_name(oligo_name)
      render :text => "Oligo design name is: #{oligo_design.oligo_name}, Gene is: #{gene_code}"
    else
      render :text => "Oligo name is: #{oligo_name}, Gene is: #{gene_code}, Curr format?: #{curr_format}"
    end
  end
  
  def test3
    @synth_ids      = [80, 81, 82, 97]
    @vol            = 10
    @ids_and_plates = SynthOligo.find_by_sql(["SELECT synth_oligos.id, MAX(oligo_wells.oligo_plate_nr) AS 'working_plate'
                         FROM synth_oligos JOIN oligo_wells ON synth_oligos.id = oligo_wells.synth_oligo_id
                         WHERE synth_oligos.id IN (?) AND oligo_wells.well_rem_volume > ?
                         GROUP BY synth_oligos.id
                         ORDER BY synth_oligos.id, oligo_plate_nr", @synth_ids, @vol])
    @plates         = @ids_and_plates.map {|id_plate| id_plate.working_plate }.uniq
    @idplate_concat = @ids_and_plates.map {|id_plate| [id_plate.id, id_plate.working_plate].join}
    
    @plate_wells    = OligoWell.find_by_sql(["SELECT oligo_name, enzyme_code, id, oligo_plate_nr, plate_copy_code,
                                                     oligo_well_nr, well_rem_volume
                                              FROM oligo_wells
                                              WHERE oligo_wells.synth_oligo_id IN (?) AND
                                                    oligo_wells.oligo_plate_nr IN (?) AND
                                                    CONCAT(CAST(synth_oligo_id AS CHAR), oligo_plate_nr) IN (?)",
                                              @synth_ids, @plates, @idplate_concat])
    render :action => 'debug'
  end


end
