class PoolPlatesController < ApplicationController
  require_role "stanford"
  before_filter :dropdowns, :only => [:new, :edit]
  
  # GET /pool_plates
  # GET /pool_plates.xml
  def index
    @pool_plates = PoolPlate.find(:all, :include => :project, :order => "pool_plate_nr DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pool_plates }
    end
  end

  # GET /pool_plates/1
  # GET /pool_plates/1.xml
  def show
    @pool_plate = PoolPlate.find(params[:id], :include => :project)

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
        flash[:notice] = 'BioMek run was successfully created.'
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
    new_pool_plate_nr = params[:pool_plate][:pool_plate_nr]
    plate_name_chg = @pool_plate.pool_plate_nr != params[:pool_plate][:pool_plate_nr]

    if @pool_plate.update_attributes(params[:pool_plate])
        
    # if plate name(biomek run name) was changed, also update pool_wells, and aliquots table 
    # for that plate
      if plate_name_chg
        PoolWell.update_all("pool_plate_nr = '#{new_pool_plate_nr}'", ["pool_plate_id = ?", @pool_plate.id])
        @pool_wells = PoolWell.find_all_by_pool_plate_id(params[:id]) 
        if @pool_wells
          @pool_well_ids = @pool_wells.map { |well| well.id }
          Aliquot.update_all( "plate_to = '#{new_pool_plate_nr}'",["pool_well_id IN (?)", @pool_well_ids] )
        end  
      end
        
      flash[:notice] = 'BioMek run was successfully updated.'
      redirect_to(@pool_plate)
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
  
protected
  def dropdowns
    @projects           = Project.find(:all)
  end
end
