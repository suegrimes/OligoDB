class FlagDefsController < ApplicationController
  require_role "stanford"
  require_role "admin", :for => [:new, :create, :destroy]
  
  # GET /flag_defs
  def index
    @flag_defs = FlagDef.find(:all, :order => :flag_value)
  end

  # GET /flag_defs/1
  def show
    @flag_def = FlagDef.find(params[:id])
  end

  # GET /flag_defs/new
  def new
    @flag_def = FlagDef.new
  end

  # GET /flag_defs/1/edit
  def edit
    @flag_def = FlagDef.find(params[:id])
  end

  # POST /flag_defs
  def create
    @flag_def = FlagDef.new(params[:flag_def])

    if @flag_def.save
      flash[:notice] = 'Flag definition was successfully created.'
      redirect_to(@flag_def)
    else
      render :action => "new" 
    end
   end

  # PUT /flag_defs/1
  def update
    @flag_def = FlagDef.find(params[:id])

    if @flag_def.update_attributes(params[:flag_def])
      flash[:notice] = 'Flag definition was successfully updated.'
      redirect_to(@flag_def) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /flag_defs/1
  def destroy
    @flag_def = FlagDef.find(params[:id])
    @flag_def.destroy

    redirect_to(flag_defs_url)
  end

  
  
end
