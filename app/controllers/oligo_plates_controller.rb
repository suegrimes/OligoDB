class OligoPlatesController < ApplicationController
  require_role "stanford"
  
  # GET /oligo_plates
  def index
    @oligo_plates = OligoPlate.find_sorted_with_loc(params[:platenum])
  end

  # GET /oligo_plates/1
  def show
    @oligo_plate = OligoPlate.find(params[:id], :include => :storage_location )
  end

  # GET /oligo_plates/new
  def new
    @plates_wo_copies = OligoPlate.find(:all, :select => "oligo_plate_num", 
                                        :conditions => "plate_copy_code <> 'S'",
                                        :group => "oligo_plate_num HAVING MAX(plate_copy_code) < 'C'").map{|p| p.oligo_plate_num.to_i}
                                        
    @plate_nrs = OligoPlate.find(:all, :select => 'id, oligo_plate_nr',
                                       :conditions => ["CAST(oligo_plate_num AS UNSIGNED) IN (?) AND plate_copy_code IN (?) AND plate_depleted_flag = 'N'",
                                                       @plates_wo_copies, OligoPlate::SOURCE_FOR_COPY],
                                       :order => 'plate_copy_code DESC, CAST(oligo_plate_num AS UNSIGNED)')
  end
  
  def copy_params
    @source_plate = OligoPlate.find_by_sql(["SELECT oligo_plates.*, MIN(oligo_wells.well_rem_volume) AS min_vol " +
                                           "FROM oligo_plates "                                                  +
                                           "  JOIN oligo_wells ON oligo_wells.oligo_plate_id = oligo_plates.id " +
                                           "WHERE "                                                              +
                                           "   oligo_plates.id = ? "                                             +
                                           "GROUP BY "                                                           +
                                           "   oligo_plates.id", params[:oligo_plate][:id]])[0]
    # minimum and total volumes, at source plate concentration
    @min_vol_s     = (@source_plate.min_vol.to_i - OligoWell::BUFFER_VOL)
    @total_vol_s   = params[:total_vol].to_i
    
    # minimum and total volumes, at copy plate concentration
    @dilution_factor = @source_plate.oligo_conc_um / params[:copy_conc].to_i
    @min_vol_c      = @min_vol_s   * @dilution_factor
    @total_vol_c    = @total_vol_s * @dilution_factor
    
    if @total_vol_s > @min_vol_s
      flash[:notice] = "Insufficient volume in source plate wells.  Please dilute concentration, or pipette < #{@min_vol_s}ul " +
                            "(#{@source_plate.oligo_conc_um}uM)"
      redirect_to :action => :new
    else
      @plate_parsed = parse_plate(@source_plate.oligo_plate_nr)
      @copy_conc    = params[:copy_conc]
      @copy_code    = params[:copy_code]
      @copy_plate   = [@plate_parsed[0], params[:copy_code]].join
      @nr_copies    = params[:nr_copies].to_i
      @first_num    = OligoPlate.find_max_copy_num(@plate_parsed[0], params[:copy_code]) + 1
      render :action => 'copy_params'
    end
  end
  
  def create_plates
    @rc = 0
    @total_vol = 0
    params[:vol].each {|vol| @total_vol += vol.to_i }
    
    if @total_vol != params[:total_vol_c].to_i
      flash[:notice] = "Volume error:  Sum of copy plate volumes (#{@total_vol}) not = total volume out of source plate (#{params[:total_vol_c]}) "
      redirect_to :action => 'new'
    else
      @copy_plate_nrs = params[:copy_plate_nr].to_a 
      @copy_plates = create_plate_array(params)
      @rc = OligoPlate.create_copy_plates(@copy_plates, params[:source_plate_id])
      @rc = OligoWell.create_copy_wells(@copy_plates, params[:source_plate_id])                 if @rc == 0
      @nr_wells_upd = OligoWell.decrement_wells(params[:source_plate_id], params[:total_vol_s]) if @rc == 0
      @source_plate = OligoPlate.find(params[:source_plate_id])                                 if @rc == 0
      
      if @rc == 0 && @nr_wells_upd > 0
        flash[:notice] = "#{@copy_plate_nrs.size} copy plates successfully created from source plate: " +
                         "#{@source_plate.oligo_plate_nr}"
        redirect_to :action => 'index', :platenum => @source_plate.oligo_plate_num.to_i
      else
        flash[:notice] = "ERROR - Unsuccessful creation of copy plates from source plate: #{@source_plate.oligo_plate_nr}"
        redirect_to :action => 'new'
      end
    end
  end

  # GET /oligo_plates/1/edit
  def edit
    @storage_locations = StorageLocation.find(:all)
    @oligo_plate = OligoPlate.find(params[:id], :include => :storage_location)
  end

  def edit_multi
    @storage_locations = StorageLocation.find(:all)
    @oligo_plates = OligoPlate.find_sorted_with_loc
  end
  
  # PUT /oligo_plates/1
  def update
    @oligo_plate = OligoPlate.find(params[:id])
    
    if @oligo_plate.update_attributes(params[:oligo_plate])
      flash[:notice] = 'OligoPlate was successfully updated.'
      redirect_to(@oligo_plate) 
    else
      render :action => "edit" 
    end
  end

  def upd_multi
    OligoPlate.update(params[:oligo_plate].keys, params[:oligo_plate].values)
    flash[:notice] = 'Oligo plate(s) successfully updated'
    redirect_to(oligo_plates_url)
  end

  # DELETE /oligo_plates/1
  def destroy
    @oligo_plate = OligoPlate.find(params[:id])
    @oligo_plate.destroy
    redirect_to(oligo_plates_url) 
  end
  
private
  def parse_plate(oligo_plate)
    pos_dash  = oligo_plate.index('_').to_i              # position of '_' in plate number
    pos_copy  = oligo_plate.index(/\D/, pos_dash+1).to_i # position of first non-digit after '_' (or nil)
    
    # if alpha character found in plate number, remove it
    base_plate = (pos_copy > 0 ? oligo_plate.slice(0, pos_copy) : oligo_plate)
    
    # extract numeric digits of plate number (starting from first position after dash
    plate_num  = base_plate.slice((pos_dash+1)..-1)
    
    # extract copy code character if one was found
    copy_code  = (pos_copy > 0 ? oligo_plate.slice(pos_copy, oligo_plate.length) : '')
    
    return [base_plate, plate_num, copy_code]
  end
  
  def create_plate_array(params) 
    plate_array = []
    copy_plates = params[:copy_plate_nr].to_a
    oligo_conc  = params[:oligo_conc].to_a
    te_conc     = params[:te_conc].to_a
    vol         = params[:vol].to_a
    
    max_indx = params[:nr_copies].to_i - 1
    
    for i in 0..max_indx
      break if copy_plates[i].nil?
      
      plate_parsed = parse_plate(copy_plates[i]) 
      plate_array[i] = {'oligo_plate_nr'  => copy_plates[i],
                        'base_plate'      => plate_parsed[0],
                        'oligo_plate_num' => plate_parsed[1],
                        'plate_copy_code' => plate_parsed[2],
                        'oligo_conc_um'   => oligo_conc[i],
                        'te_concentration' => te_conc[i],
                        'volume'           => vol[i]} 
    end
    return plate_array
  end
  
end
