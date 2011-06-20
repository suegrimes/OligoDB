class ArchiveOligoDesignsController < ApplicationController
  def show
    @oligo_design = ArchiveOligoDesign.find(params[:id] )
    @comments     = @oligo_design.comments.sort_by(&:created_at).reverse
    render :action => 'show'
  end

end
