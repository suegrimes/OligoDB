class PoolPlatesController < ApplicationController
  # GET /pool_plates
  # GET /pool_plates.xml
  def index
    @pool_plates = PoolPlate.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pool_plates }
    end
  end

  def poolparams
    @enzymes = OligoPlate.find(:all, :select => "DISTINCT(enzyme_code)")

    respond_to do |format|
      format.html # poolparams.html.erb
      format.xml  { render :xml => @pool_plates }
    end
  end
  
  def setgenevol
    @enzymes = params[:pool_params][:enzyme]
    @dest_plate = params[:dest_plate]
    @well_number = params[:well_number]
    @default_vol = params[:default_vol]
    @max_vol_well = params[:max_vol_well]
    
    @oligoplates = OligoPlate.find_plates_for_enz_with_vol(@enzymes, @default_vol)
   
    respond_to do |format|
      format.html
    end
  end

  # GET /pool_plates/1
  # GET /pool_plates/1.xml
  def show
    @pool_plate = PoolPlate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pool_plate }
    end
  end

  # GET /pool_plates/new
  # GET /pool_plates/new.xml
  def new
    @pool_plate = PoolPlate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pool_plate }
    end
  end

  # GET /pool_plates/1/edit
  def edit
    @pool_plate = PoolPlate.find(params[:id])
  end

  # POST /pool_plates
  # POST /pool_plates.xml
  def create
    @pool_plate = PoolPlate.new(params[:pool_plate])

    respond_to do |format|
      if @pool_plate.save
        flash[:notice] = 'PoolPlate was successfully created.'
        format.html { redirect_to(@pool_plate) }
        format.xml  { render :xml => @pool_plate, :status => :created, :location => @pool_plate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pool_plate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pool_plates/1
  # PUT /pool_plates/1.xml
  def update
    @pool_plate = PoolPlate.find(params[:id])

    respond_to do |format|
      if @pool_plate.update_attributes(params[:pool_plate])
        flash[:notice] = 'PoolPlate was successfully updated.'
        format.html { redirect_to(@pool_plate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pool_plate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pool_plates/1
  # DELETE /pool_plates/1.xml
  def destroy
    @pool_plate = PoolPlate.find(params[:id])
    @pool_plate.destroy

    respond_to do |format|
      format.html { redirect_to(pool_plates_url) }
      format.xml  { head :ok }
    end
  end
end
