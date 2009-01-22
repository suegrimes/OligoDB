class AliquotsController < ApplicationController
  # GET /aliquots
  # GET /aliquots.xml
  def index
    @aliquots = Aliquot.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @aliquots }
    end
  end

  # GET /aliquots/1
  # GET /aliquots/1.xml
  def show
    @aliquot = Aliquot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @aliquot }
    end
  end

  # GET /aliquots/new
  # GET /aliquots/new.xml
  def new
    @aliquot = Aliquot.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @aliquot }
    end
  end

  # GET /aliquots/1/edit
  def edit
    @aliquot = Aliquot.find(params[:id])
  end

  # POST /aliquots
  # POST /aliquots.xml
  def create
    @aliquot = Aliquot.new(params[:aliquot])

    respond_to do |format|
      if @aliquot.save
        flash[:notice] = 'Aliquot was successfully created.'
        format.html { redirect_to(@aliquot) }
        format.xml  { render :xml => @aliquot, :status => :created, :location => @aliquot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @aliquot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /aliquots/1
  # PUT /aliquots/1.xml
  def update
    @aliquot = Aliquot.find(params[:id])

    respond_to do |format|
      if @aliquot.update_attributes(params[:aliquot])
        flash[:notice] = 'Aliquot was successfully updated.'
        format.html { redirect_to(@aliquot) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @aliquot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /aliquots/1
  # DELETE /aliquots/1.xml
  def destroy
    @aliquot = Aliquot.find(params[:id])
    @aliquot.destroy

    respond_to do |format|
      format.html { redirect_to(aliquots_url) }
      format.xml  { head :ok }
    end
  end
end
