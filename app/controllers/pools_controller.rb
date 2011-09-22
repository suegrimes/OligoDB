class PoolsController < ApplicationController
  require_role "stanford"
  before_filter :dropdowns, :only => [:new, :edit, :edit_multi, :addwells]
  
  # GET /pools
  def index
    # Need to do SQL left join for the instance where pool exists, but has no pool wells assigned.
    # Rails :join will do inner join, and not list the pool which does not have wells
    # Rails :include does not use the select, and do the summation of # oligos
    @pools = Pool.find(:all, :joins => 'left join storage_locations on pools.storage_location_id = storage_locations.id 
                                        left join subpools on pools.id = subpools.pool_id
                                        left join pool_wells on subpools.pool_well_id = pool_wells.id',
                             :select => "pools.*, storage_locations.room_nr, sum(pool_wells.nr_oligos) as 'nr_oligos'",
                             :order => 'pools.tube_label',
                             :group => 'pools.id')
    #render :action => 'debug'
  end

  # GET /pools/1
  def show
    @pool = Pool.find(params[:id], :include => :pool_wells,
                      :order => "pool_wells.pool_plate_nr, pool_wells.pool_well_nr")
    
    # Check for situation where subpools/pool_wells is nil (ie new pool, with no currently attached pool_wells)
    @pool_nroligos = 0
    
    if @pool.pool_wells
      @pool.pool_wells.each do |pool_well|
        @pool_nroligos += pool_well.nr_oligos
      end
    end
    
  end

  # GET /pools/new
  def new
    @pool = Pool.new
  end

  # GET /pools/1/edit
  def edit
    @pool = Pool.find(params[:id])
  end
  
  def edit_multi
    @pools = Pool.find(:all, :include => :storage_location,
                             :order => "project_id, pool_name")
  end
  
  def upd_multi
    Pool.update(params[:pool].keys, params[:pool].values)
    flash[:notice] = 'Pool(s) successfully updated'
    redirect_to(pools_url)
  end

  # POST /pools
  def create
    @pool = Pool.new(params[:pool])

      if @pool.save
        flash[:notice] = 'Pool was successfully created.'
        redirect_to :action => 'addwells', :pool_id => @pool.id, :biomek => params[:biomek]
      else
        dropdowns
        render :action => "new" 
    end
    
  end

  # PUT /pools/1
  # PUT /pools/1.xml
  def update
    @pool = Pool.find(params[:id])

    if @pool.update_attributes(params[:pool])
      flash[:notice] = 'Pool was successfully updated.'
      redirect_to(@pool) 
    else
      render :action => "edit"
    end
  end
  
  def upd_pool_vol
    Pool.upd_pool_vol(params[:pool_id].to_a)
    flash[:notice] = "Pool volume updated"
    redirect_to pool_path(params[:pool_id])
  end
  
  def addwells
    @pool = Pool.find(params[:pool_id])
    @pool_wells = PoolWell.find_for_project_enzyme_and_biomek_string(@pool, params[:biomek])
  end
  
  def showwells
#    @pool = Pool.find(params[:pool_id])
#    @pool_wells = PoolWell.find_all_by_pool_plate_id(params[:pool_plate][:id])
  end

  def upd_pool_wells
    pool_ids_for_recalc = []
    pool_ids_for_conc_del = []
    
    params[:pool_well].each do |well|
      @subpool = Subpool.find(:first,
                              :conditions => ['subpools.pool_well_id = ? AND subpools.pool_id = ?', well[:id], params[:pool_id]])
      
      if well.has_key?(:pool_id)
        pool_ids_for_recalc.push(well[:pool_id])
        
        # if pool/well was checked (well.has_key?(:pool_id)), insert subpool or update vol/conc
        ul_to_pool = (well[:ul_to_pool].to_d > 0 ? well[:ul_to_pool].to_d : 1)
        
        if @subpool
          pool_ids_for_conc_del.push(well[:pool_id]) if @subpool.ul_chgd_and_conc_not_chgd?(well)
          @subpool.update_attributes(:nr_oligos => well[:nr_oligos],
                                     :ul_to_pool => ul_to_pool,
                                     :oligo_conc_nm => well[:oligo_conc_nm])
          
                  
        else
          pool_ids_for_conc_del.push(well[:pool_id]) if well[:oligo_conc_nm].blank?
          @subpool = Subpool.create(:pool_well_id  => well[:id],
                                    :pool_id       => well[:pool_id],
                                    :nr_oligos     => well[:nr_oligos],
                                    :ul_to_pool    => ul_to_pool,
                                    :oligo_conc_nm => well[:oligo_conc_nm])
        end
        
      elsif @subpool
        # pool/well is unchecked, but previously belonged to this pool, delete subpool entry
        pool_ids_for_recalc.push(@subpool.pool_id)
        pool_ids_for_conc_del.push(@subpool.pool_id)
        @subpool.destroy
      end
    end
    
    # Store total pool volume
    pool_ids_for_recalc.uniq!
    #flash[:notice] = "Pool ids #{pool_ids_for_recalc.inspect} had volume updated"
    Pool.upd_pool_vol(pool_ids_for_recalc)
    
    # Delete concentrations if volume changed, but not concentration
    pool_ids_for_conc_del.uniq!
    #flash[:notice] = "Pool ids #{pool_ids_for_conc_del.inspect} were updated with concentration = 0"
    Subpool.del_oligo_conc(pool_ids_for_conc_del)
    
#    render :action => 'debug'
    flash[:notice] = 'Pool successfully updated for selected well(s)'
    redirect_to(Pool.find_by_id(params[:pool_id]))
  end

  # DELETE /pools/1
  # DELETE /pools/1.xml
  def destroy
    @pool = Pool.find(params[:id])
    @pool.destroy

    respond_to do |format|
      format.html { redirect_to(pools_url) }
      format.xml  { head :ok }
    end
  end
  
protected
  def dropdowns
    @pool_plates        = PoolPlate.find(:all)
    @storage_locations  = StorageLocation.find(:all)
    @projects           = Project.find(:all)
    @enzymes_for_select = OligoDesign::ENZYMES_WO_GAPFILL.collect {|enz| LabelValue.new(enz, enz)}
  end
end
