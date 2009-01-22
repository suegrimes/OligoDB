class PoolWellsController < ApplicationController
  # GET /pool_wells
  # GET /pool_wells.xml
  def index
    @pool_wells = PoolWell.find(:all)

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

  # POST /pool_wells
  # POST /pool_wells.xml
  def create
    @pool_well = PoolWell.new(params[:pool_well])

    respond_to do |format|
      if @pool_well.save
        flash[:notice] = 'PoolWell was successfully created.'
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
        flash[:notice] = 'PoolWell was successfully updated.'
        format.html { redirect_to(@pool_well) }
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
