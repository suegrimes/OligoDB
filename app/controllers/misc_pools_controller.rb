class MiscPoolsController < ApplicationController
  require_role "admin", :for_all_except => [:new_query, :show, :index]
  
  def new_query
    @min_plate, @max_plate = MiscPlate.find_min_and_max_plates
    @min_date, @max_date   = MiscPlate.find_min_and_max_dates
    # Invert hash keys/values (ie hash value first, then key); convert to array, sort and add blank first value
    @oligo_types = MiscOligo::OLIGO_TYPE.invert.to_a.sort.insert(0,'')  
  end
  
  def list_oligos
    sql_where_clause = define_conditions(params)
    @misc_oligos = MiscOligo.find(:all, :include => :misc_plate, :conditions => sql_where_clause)
    @checked = false
    @misc_pool = MiscPool.new
    @storage_locations = StorageLocation.find(:all, :order => "room_nr, shelf_nr")
    render :action => 'list_oligos'
  end
  
  # GET /misc_pools
  # GET /misc_pools.xml
  def index
    #sql_where_clause = define_conditions(params)
    @misc_pools = MiscPool.find(:all) 
    render :action => 'index'
  end

  # GET /misc_pools/1
  # GET /misc_pools/1.xml
  def show
    @misc_pool = MiscPool.find(params[:id], :include => {:misc_pool_oligos => :misc_oligo})
    render :action => 'show'
  end

  # GET /misc_pools/1/edit
  def edit
    @misc_pool = MiscPool.find(params[:id])
    @storage_locations = StorageLocation.find(:all, :order => "room_nr, shelf_nr")
  end

  # POST /misc_pools
  # POST /misc_pools.xml
  def create
    @misc_pool = MiscPool.new(params[:misc_pool])
    if @misc_pool.save
    
      params[:oligo_id].keys.each do |oligo_id|
        @misc_pool.misc_pool_oligos.build(:misc_pool_id => @misc_pool.id, :misc_oligo_id => oligo_id)
      end

      if @misc_pool.save
        flash[:notice] = "Misc pool successfully created with #{params[:oligo_id].size} oligos"
        redirect_to(@misc_pool)
      else
        flash[:error] = 'Error saving oligos to pool - please delete the pool and try request again'
        render :action => :index 
      end
      
    else
      # Validation error in entering misc pool
      @misc_oligos = MiscOligo.find(:all, :include => :misc_plate, :conditions => ["id in (?)", params[:oligo_id].keys])
      @checked = true
      @storage_locations = StorageLocation.find(:all, :order => "room_nr, shelf_nr")
      render :action => :list_oligos
    end
  end

  # PUT /misc_pools/1
  # PUT /misc_pools/1.xml
  def update
    @misc_pool = MiscPool.find(params[:id])

    if @misc_pool.update_attributes(params[:misc_pool])
      flash[:notice] = 'MiscPool was successfully updated.'
      redirect_to(@misc_pool)
    else
      render :action => "edit"
    end
  end

  # DELETE /misc_pools/1
  # DELETE /misc_pools/1.xml
  def destroy
    @misc_pool = MiscPool.find(params[:id])
    @misc_pool.destroy

    redirect_to(misc_pools_url)
  end
  
protected
  def define_conditions(params)
    @where_select = []
    @where_values = []
    
    if params[:oligo_type] && !params[:oligo_type].blank?
      @where_select.push('oligo_type = ?')
      @where_values.push(params[:oligo_type])
    end
    
    db_fld = 'CAST(SUBSTRING(misc_oligos.plate_number,2,2) AS UNSIGNED)'
    @where_select, @where_values = sql_conditions_for_range(@where_select, @where_values, params[:plate_from], params[:plate_to], db_fld)
    
    db_fld = 'misc_plates.synthesis_date'
    @where_select, @where_values = sql_conditions_for_range(@where_select, @where_values, params[:date_from], params[:date_to], db_fld)
       
    sql_where_clause = (@where_select.length == 0 ? [] : [@where_select.join(' AND ')].concat(@where_values))
    return sql_where_clause
  end
  
  def sql_conditions_for_range(where_select, where_values, from_fld, to_fld, db_fld)
    if !from_fld.blank? && !to_fld.blank?
      where_select.push "#{db_fld} BETWEEN ? AND ?"
      where_values.push(from_fld, to_fld) 
    elsif !from_fld.blank? # To field is null or blank
      where_select.push("#{db_fld} >= ?")
      where_values.push(from_fld)
    elsif !to_fld.blank? # From field is null or blank
      where_select.push("(#{db_fld} IS NULL OR #{db_fld} <= ?)")
      where_values.push(to_fld)
    end  
    return where_select, where_values 
  end
  
end
