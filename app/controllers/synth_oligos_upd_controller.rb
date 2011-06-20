class SynthOligosController < ApplicationController
  require_role "stanford"
  
  # GET /synth_oligos
  def index
    @synth_oligos = SynthOligo.find(:all)
  end

  # GET /synth_oligos/1
  def show
    @synth_oligo = SynthOligo.find_id_incl_annot(params[:id])
    @comments    = @synth_oligo.comments.sort_by(&:created_at).reverse
  end
  
  # GET /synth_oligos/1/edit
  def edit
    @synth_oligo = SynthOligo.find(params[:id])
  end

  # PUT /synth_oligos/1
  def update
    @synth_oligo = SynthOligo.find(params[:id])

    if @synth_oligo.update_attributes(params[:synth_oligo])
      flash[:notice] = 'SynthOligo was successfully updated.'
      redirect_to(@synth_oligo) 
    else
      render :action => "edit"
    end
  end
 
  #*******************************************************************************************#
  # Methods for input of parameters for retrieval of specific oligo inventory                 #
  #*******************************************************************************************#
  def select_project
    @projects = Project.find(:all)
  end
  
  def select_params
    @versions = Version.find(:all)
    @project_id = (params[:project] ? params[:project][:project_id] : '')
    
    if !@project_id.blank?
      @proj_genes = ProjectGene.find_proj_genes(@project_id)
      @project    = Project.find_by_id(@project_id)
      @version    = Version.find(@project.version_id) # set version as default for select box
      render :action => 'select_proj_genes'
    else
      @version = Version.curr_version.find(:first) # set version as default for select box
      render :action => 'select_genes_or_ids'
    end   
  end
   
  #*******************************************************************************************#
  # Method for listing oligo inventory, based on parameters entered above                     #
  #*******************************************************************************************#
  def list_inventory_debug
    render :action => 'debug'
  end
  
  def list_inventory  
    param_type = params[:param_type] ||= 'proj_gene'
    @rpt_type  = params[:rpt_type]
    
    error_found = false
    @condition_test = []
    @condition_array = []
    
    # check for correct number of parameters entered
    # must have project/gene(s), or id(s)
    @rc = (param_type == 'gene_id' ? check_params2(params, 'list') : check_params1(params, 'list'))
    
    # check for errors passed by parameter check, otherwise get requested oligos
    case @rc
      when /e\d/
        error_found    = true
      
      when 'id' #list of ids entered
        @condition_test.push("CAST(SUBSTRING_INDEX(synth_oligos.oligo_name,'_',1) AS UNSIGNED) IN (?)")
        @param_list = create_array_from_text_area(params[:oligo_ids])
      
      when 'g'  # gene list entered
        @condition_test.push('gene_code IN (?)')
        @gene_list  = (param_type == 'gene_id' ? create_array_from_text_area(params[:genes]) : 
                                                 params[:oligo_design][:gene_code]) 
        @param_list = ProjectGene.genelist(nil, @gene_list)
        
      when 'p' # project entered, with "all genes" selected, or no selection made
        @condition_test.push('gene_code IN (?)')
        @param_list = ProjectGene.genelist(params[:project], nil)
        
      else
        error_found = true
        flash[:notice] = "Unknown error, rc = #{@rc}"
    end
    
    if !error_found
      # add condition for well remaining volume gt threshold volume (currently hardcoded as 10)
      @condition_test.push('oligo_wells.well_rem_volume > ?')
      @condition_array[0] = @condition_test.join(' AND ')
      @condition_array.push(@param_list)
      @condition_array.push(10)
      
      # add condition for version id(s)
      version_id_array = params[:version][:id]
      if !version_id_array[0].blank?
        @condition_array[0] += ' AND version_id IN (?)'
        @condition_array.push(params[:version][:id])
      end
      
      # find oligos
      @params_list1 = @param_list.join(',')
      @synth_oligos = SynthOligo.find_plate_wells_with_conditions(@condition_array)
      error_found = check_if_blank(@synth_oligos, 'oligos', 'parameters')
    end
    
#    if error_found && param_type == 'proj_gene'
#      redirect_to :action => 'select_genes_and_ver', :project => params[:project]
#    elsif error_found
#      redirect_to :action => 'select_genes_or_ids', 
#                  :genes => params[:genes], :oligo_ids => params[:oligo_ids]  
    if error_found
      redirect_to :action => 'select_project'
#    else
#      render :action => 'debug'
    elsif params[:rpt_type] == 'design'
      render :action => 'list_designs' 
    else
      render :action => 'list_inventory'
    end 
  end

  #*******************************************************************************************#
  # Method for export of inventory details to Excel                                           #
  #*******************************************************************************************#
  def export_inventory
    #params[:rpt_type] = 'inventory'
    @oligo_ids = params[:export_id]
    
    if params[:rpt_type] == 'inventory'
      @synth_oligos = SynthOligo.find_plate_wells_with_conditions(["synth_oligos.id IN (?)", @oligo_ids])
      @filename = "oligoinventory_" + Date.today.to_s + ".xls"
    else
      @synth_oligos = SynthOligo.find_with_id_list(@oligo_ids)
      @filename = "oligoinv_designs_" + Date.today.to_s + ".xls"
    end   
   
    headers['Content-Type']="application/vnd.ms-excel"
    headers['Content-Disposition']="attachment;filename=\"" + @filename + "\""
    
    if params[:rpt_type] == 'inventory'
      render :action => 'export_inventory', :layout => false
    else
      render :action => 'export_design', :layout => false
    end
  end

  #*******************************************************************************************#
  # Methods for listing, displaying and exporting created synthesis order files               #
  #*******************************************************************************************# 
  def list_files
    @synth_files = CreatedFile.find_all_by_content_type("synthesis",
                     :include => :researcher, 
                     :order => "created_at DESC, created_file DESC")
  end

  def show_files
    @synth_file = CreatedFile.listfile(params[:created_file_id])
    #send_data(@synth_file, :type => "text", :disposition => "inline")
  end
  
  def export_file
    @synth_file = CreatedFile.find(params[:id])
    send_file(@synth_file.file_path, :type => 'text', :filename => "#{@synth_file.created_file}.txt")
  end
  
  def delete_file
    @synth_file = CreatedFile.find(params[:id])
    @file_path = @synth_file.file_path
    
    # delete file from file system
    File.delete(@file_path) if FileTest.exist?(@file_path)
    
    # delete file entry from SQL uploads table
    @synth_file.destroy
    redirect_to :action => 'list_files'
  end

 
 private
 
  def check_params1(params, action='list')
      
    if (params[:researcher].blank? && action == 'order')
      flash[:notice] = 'Please select researcher for this order, plus project, gene(s) or id(s)'
      rc = 'e1'
    
    elsif params[:oligo_design] && params[:oligo_design][:gene_code]
      gene_list = params[:oligo_design][:gene_code]
      rc = (gene_list[0].blank? ? 'p' : 'g')  #gene_list[0].blank? if "all genes" for project, selected
      
    elsif params[:project]
      rc = 'p'
      
    else
      flash[:notice] = 'Please select project, gene(s) or id(s)' 
      rc = 'e2'
    end
    
    return rc  
  end
  
  def check_params2(params, action='list')
    # when params[:genes] is too large, unpredictable browser errors occur, so trap size 
    # error before doing any other processing
    @nr_genes = params[:genes].split.size if params[:genes]
    
    if (@nr_genes && @nr_genes > 400)
      params[:genes] = []  #reset params[:genes] to avoid browser errors
      flash[:notice] = "Too many genes (#{@nr_genes}) in list - please limit to 400 genes"
      rc = 'e3'
      
    elsif (params[:researcher].blank? && action == 'order')
      flash[:notice] = 'Please select researcher for this order, plus project, gene(s) or id(s)'
      rc = 'e1'
      
    elsif !params[:oligo_ids].blank?
      rc = 'id'
    
    elsif !params[:genes].blank?
      rc = 'g'
      
    else
      flash[:notice] = 'Please select project, gene(s) or id(s)' 
      rc = 'e2'
    end
    
    return rc  
  end

end
