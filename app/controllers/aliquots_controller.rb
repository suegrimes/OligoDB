class AliquotsController < ApplicationController
  require_role "stanford"
  
  # GET /aliquots
  def index
    params[:pool_well_id] ||= 99999
    @pool_well = PoolWell.find(params[:pool_well_id])
    @aliquots = Aliquot.find_all_with_dtls(["aliquots.pool_well_id = ?", params[:pool_well_id]])
                 
    if @aliquots.empty? || @aliquots.nil?
      flash[:notice] = "No oligos found for pool well id #{params[:pool_well_id]}"
    end
    
    render :action => 'index'
  end

end
