class SelectorSitesController < ApplicationController
  require_role "stanford"
  
  # GET /selector_sites
  # GET /selector_sites.xml
  def index
    @selector_sites = SelectorSite.curr_ver.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @selector_sites }
    end
  end

  # GET /selector_sites/1
  # GET /selector_sites/1.xml
  def show
    @selector_site = SelectorSite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @selector_site }
    end
  end

  # GET /selector_sites/new
  # GET /selector_sites/new.xml
  def new
    @selector_site = SelectorSite.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @selector_site }
    end
  end

  # GET /selector_sites/1/edit
  def edit
    @selector_site = SelectorSite.find(params[:id])
  end

  # POST /selector_sites
  # POST /selector_sites.xml
  def create
    @selector_site = SelectorSite.new(params[:selector_site])

    respond_to do |format|
      if @selector_site.save
        flash[:notice] = 'SelectorSite was successfully created.'
        format.html { redirect_to(@selector_site) }
        format.xml  { render :xml => @selector_site, :status => :created, :location => @selector_site }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @selector_site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /selector_sites/1
  # PUT /selector_sites/1.xml
  def update
    @selector_site = SelectorSite.find(params[:id])

    respond_to do |format|
      if @selector_site.update_attributes(params[:selector_site])
        flash[:notice] = 'SelectorSite was successfully updated.'
        format.html { redirect_to(@selector_site) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @selector_site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /selector_sites/1
  # DELETE /selector_sites/1.xml
  def destroy
    @selector_site = SelectorSite.find(params[:id])
    @selector_site.destroy

    respond_to do |format|
      format.html { redirect_to(selector_sites_url) }
      format.xml  { head :ok }
    end
  end
end
