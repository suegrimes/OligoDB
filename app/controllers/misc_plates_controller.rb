class MiscPlatesController < ApplicationController
  #require_role "admin", :for_all_except => [:new_query, :show, :index]
  
  def new_query
    @min_plate, @max_plate = MiscPlate.find_min_and_max_plates
    @min_date, @max_date   = MiscPlate.find_min_and_max_dates
  end
  
  # GET /misc_plates
  # GET /misc_plates.xml
  def index
    sql_where_clause = define_conditions(params)
    @misc_plates = MiscPlate.find_all_incl_oligos(sql_where_clause)
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
  
protected
  def define_conditions(params)
    @where_select = []
    @where_values = []
    
    db_fld = 'CAST(SUBSTRING(misc_plates.plate_number,2,2) AS UNSIGNED)'
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
