class OligoWellsController < ApplicationController
  # GET /oligo_wells
  # GET /oligo_wells.xml
  def index
    if params[:plate_id]
      @oligo_wells = OligoWell.find(:all, :order => "oligo_plate_nr, id",
                              :conditions => ["oligo_plate_id = ?", params[:plate_id]])
    else
      @oligo_wells = OligoWell.find(:all, :order => "oligo_plate_nr, id")
    end  

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @oligo_wells }
    end
  end

  # GET /oligo_wells/1
  # GET /oligo_wells/1.xml
  def show
    @oligo_well = OligoWell.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @oligo_well }
    end
  end

  # GET /oligo_wells/new
  # GET /oligo_wells/new.xml
  def new
    @oligo_well = OligoWell.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @oligo_well }
    end
  end

  # GET /oligo_wells/1/edit
  def edit
    @oligo_well = OligoWell.find(params[:id])
  end

  # POST /oligo_wells
  # POST /oligo_wells.xml
  def create
    @oligo_well = OligoWell.new(params[:oligo_well])

    respond_to do |format|
      if @oligo_well.save
        flash[:notice] = 'OligoWell was successfully created.'
        format.html { redirect_to(@oligo_well) }
        format.xml  { render :xml => @oligo_well, :status => :created, :location => @oligo_well }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @oligo_well.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /oligo_wells/1
  # PUT /oligo_wells/1.xml
  def update
    @oligo_well = OligoWell.find(params[:id])

    respond_to do |format|
      if @oligo_well.update_attributes(params[:oligo_well])
        flash[:notice] = 'OligoWell was successfully updated.'
        format.html { redirect_to(@oligo_well) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @oligo_well.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /oligo_wells/1
  # DELETE /oligo_wells/1.xml
  def destroy
    @oligo_well = OligoWell.find(params[:id])
    @oligo_well.destroy

    respond_to do |format|
      format.html { redirect_to(oligo_wells_url) }
      format.xml  { head :ok }
    end
  end
end
