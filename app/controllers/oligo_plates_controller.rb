class OligoPlatesController < ApplicationController
  before_filter :login_required
  # GET /oligo_plates
  # GET /oligo_plates.xml
  def index
    @oligo_plates = OligoPlate.find(:all, :order => 'oligo_plate_nr')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @oligo_plates }
    end
  end

  # GET /oligo_plates/1
  # GET /oligo_plates/1.xml
  def show
    @oligo_plate = OligoPlate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @oligo_plate }
    end
  end

  # GET /oligo_plates/new
  # GET /oligo_plates/new.xml
  def new
    @oligo_plate = OligoPlate.new
    @source_plate = params[:source_plate]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @oligo_plate }
    end
  end

  # GET /oligo_plates/1/edit
  def edit
    @oligo_plate = OligoPlate.find(params[:id])
  end

  # POST /oligo_plates
  # POST /oligo_plates.xml
  def create
    @source_plate = params[:oligo_plate][:source_plate]
    @dest_plate   = params[:oligo_plate][:dest_plate]
    @volume       = params[:oligo_plate][:well_initial_volume]
    OligoPlate.create_copy_order(@source_plate, @dest_plate, @volume)
    
    respond_to do |format|
        flash[:notice] = 'OligoPlate copy order successfully created.'
        format.html # create.html.erb
    end
  end

  # PUT /oligo_plates/1
  # PUT /oligo_plates/1.xml
  def update
    @oligo_plate = OligoPlate.find(params[:id])

    respond_to do |format|
      if @oligo_plate.update_attributes(params[:oligo_plate])
        flash[:notice] = 'OligoPlate was successfully updated.'
        format.html { redirect_to(@oligo_plate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @oligo_plate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /oligo_plates/1
  # DELETE /oligo_plates/1.xml
  def destroy
    @oligo_plate = OligoPlate.find(params[:id])
    @oligo_plate.destroy

    respond_to do |format|
      format.html { redirect_to(oligo_plates_url) }
      format.xml  { head :ok }
    end
  end
end
