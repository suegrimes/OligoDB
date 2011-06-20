class PilotOligoDesignsController < ApplicationController  
  def show
    @oligo_design = PilotOligoDesign.find(params[:id] )
    @comments     = @oligo_design.comments.sort_by(&:created_at).reverse
    render :controller => 'oligo_designs', :action => 'show'
  end
  
  # method used for testing/debugging the methods with alter table to set autoincrement id #
  def index
    @pilot_table = PilotOligoDesign.table_name
    @oligo_table = OligoDesign.table_name
    #@next_autoincr = set_autoincr(@pilot_table, 935)
    #@next_autoincr = set_autoincr(@pilot_table, @oligo_table)
    @next_autoincr = next_autoincr(@pilot_table) 
    render :action => 'debug'
  end
  
end
