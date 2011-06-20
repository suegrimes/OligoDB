class OligoWellsController < ApplicationController
  require_role "stanford"
  
  def selectthreshold
    @vol ||= '50'
  end

  def get_wellsltvolume
    @vol    = params[:thresholdvol]
    @volnum = @vol.to_i
    
    # Check for numeric value entered for volume threshold
    if @volnum == 0 
      flash.now[:notice] = 'Please enter volume as a valid (non-zero) integer'
      render :action => 'selectthreshold' 
    
    else 
    # Volume was numeric, so find all oligo wells with remaining vol < @vol 
      @oligo_wells = OligoWell.find_wells_with_low_volume(@volnum)
      
    # Replace above statement with the two below, to return all associated daughter plates for 
    # the low volume plate/wells
    
    # @plate_wells = OligoWell.find_wells_with_low_volume(@volnum)
    # @oligo_wells = OligoWell.find_assoc_plates_for_wells(@plate_wells)
      
      respond_to do |format|
        format.html { render :action => "list_inventory" }
        format.xml  { render :xml => @oligos }
      end
    end
    
  end
  
  # GET /oligo_wells
  def index
    condition_array = (params[:plate_id] ? ["oligo_plate_id = ?", params[:plate_id]] : [])
    @oligo_wells = OligoWell.find(:all, :include => :synth_oligo,
                                        :order   => "oligo_plate_nr, oligo_wells.id",
                                        :conditions => condition_array)
  end
end