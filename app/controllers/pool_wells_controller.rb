class PoolWellsController < ApplicationController
  require_role "stanford"
  
  # GET /pool_wells
  # GET /pool_wells.xml
  def index
    @condition_array = Array.new
    if params[:pool_plate_id]
      @condition_array = ["pool_plate_id = ?", params[:pool_plate_id]]
    end
    
    @pool_wells = PoolWell.find(:all,
                                :conditions => @condition_array,
                                :order => "pool_plate_nr, pool_well_nr")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pool_wells }
    end
  end

  # GET /pool_wells/1
  # GET /pool_wells/1.xml
  def show
    @pool_well = PoolWell.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pool_well }
    end
  end

  # GET /pool_wells/new
  # GET /pool_wells/new.xml
  def new
    @pool_well = PoolWell.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pool_well }
    end
  end

  # GET /pool_wells/1/edit
  def edit
    @pool_well = PoolWell.find(params[:id])
  end
  
  def edit_multi
    @pool_wells = PoolWell.find(:all, :order => "pool_plate_nr, pool_well_nr")
    @projects = Project.find(:all)
    
    respond_to do |format|
      format.html # edit_multi.html.erb
      format.xml  { render :xml => @pool_wells }
    end
  end
  
  def upd_multi
    PoolWell.update(params[:pool_well].keys, params[:pool_well].values)
    flash[:notice] = 'BioMek well(s) successfully updated'
    redirect_to(pool_wells_url)
  end

  # POST /pool_wells
  # POST /pool_wells.xml
  def create
    @pool_well = PoolWell.new(params[:pool_well])

    respond_to do |format|
      if @pool_well.save
        flash[:notice] = 'BioMek well was successfully created.'
        format.html { redirect_to(@pool_well) }
        format.xml  { render :xml => @pool_well, :status => :created, :location => @pool_well }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pool_well.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pool_wells/1
  # PUT /pool_wells/1.xml
  def update
    @pool_well = PoolWell.find(params[:id])

    respond_to do |format|
      if @pool_well.update_attributes(params[:pool_well])
        flash[:notice] = 'BioMek well(s) successfully updated.'
        format.html { redirect_to(pool_wells_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pool_well.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pool_wells/1
  # DELETE /pool_wells/1.xml
  def destroy
    @pool_well = PoolWell.find(params[:id])
    @pool_well.destroy

    respond_to do |format|
      format.html { redirect_to(pool_wells_url) }
      format.xml  { head :ok }
    end
  end
end
