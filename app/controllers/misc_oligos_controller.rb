class MiscOligosController < ApplicationController
  require_role "admin", :for_all_except => [:new_query, :show, :index]
  
  def new_query

  end
  
  # GET /misc_oligos
  # GET /misc_oligos.xml
  def index
    @misc_oligos = MiscOligo.find_all_incl_plate
    render :action => 'index'
  end

  # GET /misc_oligos/1
  # GET /misc_oligos/1.xml
  def show
    @misc_oligo = MiscOligo.find(params[:id])
    render :action => 'show'
  end

  # GET /misc_oligos/1/edit
  def edit
    @misc_oligo = MiscOligo.find(params[:id])
  end

  # POST /misc_oligos
  # POST /misc_oligos.xml
  def create
    @misc_oligo = MiscOligo.new(params[:misc_oligo])

    if @misc_oligo.save
      flash[:notice] = 'MiscOligo was successfully created.'
      redirect_to(@misc_oligo)
    else
      render :action => "new" 
    end
  end

  # PUT /misc_oligos/1
  # PUT /misc_oligos/1.xml
  def update
    @misc_oligo = MiscOligo.find(params[:id])

    if @misc_oligo.update_attributes(params[:misc_oligo])
      flash[:notice] = 'MiscOligo was successfully updated.'
      redirect_to(@misc_oligo)
    else
      render :action => "edit"
    end
  end

  # DELETE /misc_oligos/1
  # DELETE /misc_oligos/1.xml
  def destroy
    @misc_oligo = MiscOligo.find(params[:id])
    @misc_oligo.destroy

    redirect_to(misc_oligos_url)
  end
end
