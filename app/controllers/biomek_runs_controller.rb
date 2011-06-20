class BiomekRunsController < ApplicationController
  def biomek_new
    @rnames = Researcher.find(:all, :order=>"researcher_name")
    @projects = Project.find(:all)

    respond_to do |format|
      format.html # biomek_new.html.erb
    end
  end
  
  def biomek_params
    if params[:researcher].nil? 
      flash[:notice] = 'Please select researcher for this order'
      redirect_to :action => 'biomek_new'
    
    else
      @researcher = Researcher.find(params[:researcher][:researcher_id])
      project_id  = (params[:project] ? params[:project][:project_id] : '')
      @versions   = Version.find(:all)
    
      if !project_id.blank?
        @proj_genes = ProjectGene.find_proj_genes(project_id)
        @project    = Project.find_by_id(project_id)
        render :action => 'biomek_params1'
      else
        render :action => 'biomek_params2'
      end
    end
  end
  
  def biomek_display
    # check for correct number of parameters entered 
    # Three possibilities for how genes are specified:
    # 1 - No project selected; genes entered in text area => params[:genes]
    # 2 - Project selected, and "All genes" selected in drop down list => params[:synth_oligo][:gene_code] is blank
    # 3 - Project selected, and specific genes selected in drop down list => gene list is in params[:synth_oligo][:gene_code]
    rc = check_biomek_params(params)
    
    if rc =~ /e\d/ 
      redirect_to :action => 'biomek_new'
      
    else
      # build array of conditions for select statement:
      @condition_array = define_conditions(params, rc) 
      @synth_oligos = SynthOligo.find_id_name_with_conditions(@condition_array)
    
      @researcher = Researcher.find(params[:researcher][:researcher_id])
      biomek_lbl  = run_label(params, rc)
      @dest_plate  = [Time.now.strftime("%y%m%d"), biomek_lbl, @researcher.researcher_initials].join("_")
      @default_vol = params[:default_vol]
    
      #@oligo_wells = OligoWell.find_wells_for_biomek_run(@synth_oligos, @default_vol)
      @oligo_wells = OligoWell.find_wells_for_biomek_run(@synth_oligos, 0)
      @oligo_wells.each do |well|
        enzyme = well[:enzyme_code].split(/_/)[0]
        well[:dest_well] = set_biomek_well(enzyme)
      end
   
      if @oligo_wells.size < @synth_oligos.size
        oligos_no_vol = @synth_oligos.size - @oligo_wells.size
        flash[:notice] = "Warning: #{oligos_no_vol} oligos not listed (insufficient volume in available wells)"
      end
    end
    
  end
  
  def biomek_create
    OligoWell.create_biomek_order(params[:well], params[:dest_params],
                                  params[:researcher][:id])
    
    respond_to do |format|
       #format.html
       flash[:notice] = 'Biomek template file successfully created'
       format.html { redirect_to :action => :list_files}
    end
  end
  
  def list_files
    @biomek_files = CreatedFile.list_all_by_content("BioMek")

    respond_to do |format|
      format.html # list_files.html.erb
      format.xml  { render :xml => @biomek_files }
    end
  end

  def show_files
    @biomek_file = CreatedFile.listfile(params[:created_file_id])

    respond_to do |format|
      format.html # show_files.html.erb
      format.xml  { render :xml => @biomek_file }
    end
  end
  
  def export_biomek
    @biomek_file = CreatedFile.find(params[:created_file_id])
    @filename = @biomek_file.created_file + ".xls"
    
    @biomek_contents = CreatedFile.listfile(params[:created_file_id])
    
    headers['Content-Type']="application/vnd.ms-excel"
    headers['Content-Disposition']="attachment;filename=\"" + @filename + "\""
    render :layout => false
  end

 def delete_file
    @biomek_file = CreatedFile.find(params[:id])
    @file_path = @biomek_file.file_path

    # delete file from file system
    File.delete(@file_path) if FileTest.exist?(@file_path)
    
    # delete file entry from SQL uploads table
    @biomek_file.destroy
    redirect_to :action => 'list_files'
  end

private
  def check_biomek_params(params)
    # no project entered, check that either genes, or ids entered
    if params[:project].nil?
      if !params[:oligo_ids].blank?
        return 'id'
      elsif !params[:genes].blank?
        nr_genes = params[:genes].split.size
        if nr_genes > 400
          flash[:notice] = "Too many genes (#{nr_genes}) in list - please limit to 400"
          return 'e3'
        else
          return 'gt'
        end
      else  # ids and genes are both blank
        flash[:notice] = 'Please enter project, gene(s) or id(s)'
        return 'e1'
      end
    end
        
    # Specific project was entered, check for genes
    if params[:synth_oligo] && params[:synth_oligo][:gene_code]
      gene_list = params[:synth_oligo][:gene_code]
      return (gene_list[0].blank? ? 'p' : 'gl')
    else
      flash[:notice] = 'Error in determining gene(s) selected'
      return 'e2'
    end
  end
  
  def define_conditions(params, ptype)
    condition_array = []
    condition_array[0] = 'blank'
    select_conditions = []
    
  # build gene list from project, genes and/or ids selected
    case ptype
      when 'p'
        gene_list = ProjectGene.genelist(params[:project], nil)
      when 'gt'
        gene_list = create_array_from_text_area(params[:genes])
      when 'gl'
        gene_list = params[:synth_oligo][:gene_code]
      when 'id'
        id_list = create_array_from_text_area(params[:oligo_ids], 'integer')
      else
        gene_list = ['error']
    end 
      
    if ptype == 'id'
      select_conditions.push('oligo_id IN (?)')
      condition_array.push(id_list)
    else
      select_conditions.push('gene_code IN (?)')
      condition_array.push(gene_list)
    end
 
    if params[:enzyme] && !param_blank?(params[:enzyme][:enzyme_code])          
      select_conditions.push('enzyme_code IN (?)') 
      condition_array.push(enzyme_add_gapfill(params[:enzyme][:enzyme_code]))
    end
      
    if params[:version] && !param_blank?(params[:version][:id])
      select_conditions.push('version_id IN (?)')
      condition_array.push(params[:version][:id])
    end
    
    condition_array[0] = select_conditions.join(' AND ')
    return condition_array
  end
  
  def run_label(params, ptype)
    lbl = ''
    case ptype
      when 'p'
        lbl = Project.find_by_id(params[:project][:project_id]).project_name
      when 'gt'
        gene_list = create_array_from_text_area(params[:genes])
        if gene_list.size == 1
          lbl = gene_list[0]
        else
          lbl = gene_list.size.to_s + 'GENES'
        end
      when 'gl'
        gene_list = params[:synth_oligo][:gene_code]
        if gene_list.size == 1
          lbl = gene_list[0]
        else
          lbl = gene_list.size.to_s + 'GENES'
        end
      when 'id'
        id_list = create_array_from_text_area(params[:oligo_ids], 'text')
        if id_list.size == 1
          lbl = 'ID' + id_list[0]
        else
          lbl = id_list.size.to_s + 'IDS'
        end     
    end
    
  return lbl 
  end
  
  def set_biomek_well(enzyme)
    case enzyme
      when "MseI"
        dest_well = "A1"
      when "BfaI"
        dest_well = "A2"
      when "CviQI"
        dest_well = "A3"
      when "Sau3AI"
        dest_well = "A4"
      else
        dest_well = "??"
    end 
    return dest_well
  end
  
end