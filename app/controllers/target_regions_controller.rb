class TargetRegionsController < ApplicationController
  require_role "stanford"
  
  # GET /target_regions
  # GET /target_regions.xml
  def index
    @target_regions = TargetRegion.curr_ver.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @target_regions }
    end
  end

  # GET /target_regions/1
  # GET /target_regions/1.xml
  def show
    @target_region = TargetRegion.find(params[:id], :include => :ccds)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @target_region }
    end
  end

  # GET /target_regions/new
  # GET /target_regions/new.xml
  def new
    @target_region = TargetRegion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @target_region }
    end
  end

  # GET /target_regions/1/edit
  def edit
    @target_region = TargetRegion.find(params[:id])
  end

  # POST /target_regions
  # POST /target_regions.xml
  def create
    @target_region = TargetRegion.new(params[:target_region])

    respond_to do |format|
      if @target_region.save
        flash[:notice] = 'TargetRegion was successfully created.'
        format.html { redirect_to(@target_region) }
        format.xml  { render :xml => @target_region, :status => :created, :location => @target_region }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @target_region.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /target_regions/1
  # PUT /target_regions/1.xml
  def update
    @target_region = TargetRegion.find(params[:id])

    respond_to do |format|
      if @target_region.update_attributes(params[:target_region])
        flash[:notice] = 'TargetRegion was successfully updated.'
        format.html { redirect_to(@target_region) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @target_region.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /target_regions/1
  # DELETE /target_regions/1.xml
  def destroy
    @target_region = TargetRegion.find(params[:id])
    @target_region.destroy

    respond_to do |format|
      format.html { redirect_to(target_regions_url) }
      format.xml  { head :ok }
    end
  end
end
