class InventoryController < ApplicationController
  def selectparams
    @genes = OligoDesign.unique_genes
    @enzymes = OligoDesign.unique_enzymes
  end
  
  def selectthreshold
  end

  def get_wellsltvolume
    @oligos = OligoDesign.find(:all, :include => [:oligo_wells],
               :conditions => ["oligo_wells.well_rem_volume < ?", params[:thresholdvol]])
                
    respond_to do |format|
      format.html { render :action => "list_inventory" }
      format.xml  { render :xml => @oligos }
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
