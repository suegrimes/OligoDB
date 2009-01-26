class InventoryController < ApplicationController
  def selectparams
    @genes = OligoDesign.unique_genes
    @enzymes = OligoDesign.unique_enzymes
  end
  
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
      @oligos = OligoDesign.find(:all, :include => [:oligo_wells],
               :conditions => ["oligo_wells.well_rem_volume < ?", @volnum])
          
      respond_to do |format|
        format.html { render :action => "list_inventory" }
        format.xml  { render :xml => @oligos }
      end
    end
    
  end
   
  def list_inventory
    gene = params[:design][:gene]
    enzyme = params[:design][:enzyme]
    @oligos = OligoDesign.find(:all, :include => [:oligo_wells],
#                 :select => "oligo_designs.oligo_name, 
#                             oligo_wells.oligo_plate_nr, 
#                             oligo_wells.oligo_well_nr, 
#                             oligo_wells.well_initial_volume, 
#                             oligo_wells.well_rem_volume",
                 :conditions => ["oligo_designs.gene_code = ? AND oligo_designs.enzyme_code = ?", 
                                  gene, enzyme])           

    respond_to do |format|
      format.html
      format.xml  { render :xml => @oligos }
    end
  end
end
