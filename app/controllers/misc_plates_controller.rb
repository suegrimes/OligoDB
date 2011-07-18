class MiscPlatesController < ApplicationController
  require_role "admin", :for_all_except => [:new_query, :show, :index]
  
  def new_query

  end
  
  # GET /misc_plates
  # GET /misc_plates.xml
  def index
    @misc_plates = MiscPlate.find_all_incl_oligos
    render :action => 'index'
  end

  # GET /misc_plates/1
  # GET /misc_plates/1.xml
  def show
    @misc_plate = MiscPlate.find(params[:id], :include => :misc_oligos)
    render :action => 'show'
  end

  # GET /misc_plates/1/edit
  def edit
    @misc_plate = MiscPlate.find(params[:id])
  end

  # POST /misc_plates
  # POST /misc_plates.xml
  def create
    @misc_plate = MiscPlate.new(params[:misc_plate])

    if @misc_plate.save
      flash[:notice] = 'MiscPlate was successfully created.'
      redirect_to(@misc_plate)
    else
      render :action => "new" 
    end
  end

  # PUT /misc_plates/1
  # PUT /misc_plates/1.xml
  def update
    @misc_plate = MiscPlate.find(params[:id])

    if @misc_plate.update_attributes(params[:misc_plate])
      flash[:notice] = 'MiscPlate was successfully updated.'
      redirect_to(@misc_plate)
    else
      render :action => "edit"
    end
  end

  # DELETE /misc_plates/1
  # DELETE /misc_plates/1.xml
  def destroy
    @misc_plate = MiscPlate.find(params[:id])
    @misc_plate.destroy

    redirect_to(misc_plates_url)
  end
end
