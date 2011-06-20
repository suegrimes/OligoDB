class SynthOrdersController < ApplicationController
  
  #*******************************************************************************************#
  # Methods for creating new oligo synthesis order                                            #    
  #*******************************************************************************************#
  def new_order
    @projects = Project.find(:all)
  end
  
  def select_params
    @versions = Version.find(:all)
    @rnames = Researcher.find(:all, :order=>"researcher_name")
    @project_id = (params[:project] ? params[:project][:project_id] : '')
    
    if !@project_id.blank?
      @proj_genes = ProjectGene.find_proj_genes(@project_id)
      @project    = Project.find_by_id(@project_id)
      @version    = Version.find(@project.version_id) # set version as default for select box
      render :action => 'select_proj_genes'
    else
      @version = Version.curr_version.find(:first) # set version as default for select box
      render :action => 'select_genes_ids'
    end   
  end
  
  def list_selected
    param_type = params[:param_type] ||= 'proj_gene'
    @version_id = Version::version_id_or_default(params[:version][:id])
    
    error_found = false 
    # check for correct number of parameters entered
    # must have researcher, and project/gene(s), or id(s)
    @rc = check_params(params, param_type)
    
    # check for errors passed by parameter check, otherwise get requested oligos
    if @rc =~ /e\d/
      error_found    = true
      
    else
      @condition_array = define_conditions(params, @rc, @version_id)
      excl_flagged     = (params[:excl_flagged] == 'true' ? 'yes' : 'no')
      @oligo_designs   = OligoDesign.find_oligos_with_conditions(@condition_array, @version_id,
                                 {:sort_order => 'enzyme', :excl_flagged => excl_flagged})
      # return error if no oligos found
      error_found = check_if_blank(@oligo_designs, 'oligos', @rc)      
    end
                                      
    if error_found 
      redirect_to :action => 'new_order'
    else
      @researcher = Researcher.find(params[:researcher][:researcher_id])
      @start_plate_nr = Indicator.find(1).last_oligo_plate_nr + 1
      render :action => 'list_selected'
    end 
  end

  def create_order
    @researcher = Researcher.find(params[:researcher_id]) 
    @oligos = params[:oligo] # array of hashes
    
    #Write flat file for order synthesis                       
    OligoDesign.create_synth_file(@researcher, params[:plate_start], params[:nr_wells], @oligos) 

    flash[:notice] = 'Synthesis order file(s) successfully created'
    redirect_to(synth_files_url)
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
  #*******************************************************************************************#
  # Method for checking parameters from "select_proj_genes", and "select_genes_ids" views     #
  #*******************************************************************************************#
  def check_params(params, param_type)
    if params[:researcher].blank? 
      flash[:notice] = 'Please select researcher for this order, plus project/gene(s)'
      rc = 'e1'
      
    elsif param_type == 'proj_gene'
      if params[:oligo_design] && params[:oligo_design][:gene_code]
      # if gene_list[0].blank? then "all genes" was selected from drop-down
      # set rc=p if "all genes", => retrieve all genes for the selected project
      # set rc=g otherwise,      => retrieve just the genes selected
        gene_list = params[:oligo_design][:gene_code]
        rc = (gene_list[0].blank? ? 'p' : 'gl')
      
      elsif params[:project] 
        #only project entered, so will retrieve all genes for that project
        rc = 'p'
      else
        # error - neither project or gene were selected
        flash[:notice] = 'Please select project and/or gene(s)'
        rc = 'e2'
      end
      
    else #param_type == 'gene_id'
      nr_genes = params[:genes].split.size if params[:genes]
      if nr_genes && nr_genes > 400
        params[:genes] = ''  #reset params[:genes] to avoid browser errors
        flash[:notice] = "Too many genes (#{nr_genes}) in list - please limit to 400 genes"
        rc = 'e3'
        
      # oligo ids if entered, take priority over genes, so check for ids first
      elsif !params[:oligo_ids].blank?
        rc = 'id'
      
      elsif !params[:genes].blank?
        rc = 'gt'
   
      else
        # error - both genes and oligo ids are blank
        flash[:notice] = 'Please select gene(s) or id(s)'
        rc = 'e4'
      end
    end
    
    return rc
  end
  #*******************************************************************************************#
  # Method for creating sql condition array, based on parameters entered                      #
  #*******************************************************************************************#
  def define_conditions(params, ptype, version_id)
    condition_array = []
    condition_array[0] = 'blank'
    select_conditions = []
    
    case ptype
      when 'id' #list of ids entered
        id_list = create_array_from_text_area(params[:oligo_ids], 'integer')
        select_conditions.push('id IN (?)')
        condition_array.push(id_list)
      
      when 'gl'  #gene list entered (as array from drop-down)
        gene_list      = params[:oligo_design][:gene_code]
        select_conditions.push('gene_code IN (?)')
        condition_array.push(gene_list)
      
      when 'gt'  #gene list entered (as text)
        gene_list      = create_array_from_text_area(params[:genes])
        select_conditions.push('gene_code IN (?)')
        condition_array.push(gene_list)
      
    when 'p' #project entered, without entering specific genes, so get all genes for project
        gene_list      = ProjectGene.genelist(params[:project], nil)
        select_conditions.push('gene_code IN (?)')
        condition_array.push(gene_list)
    end
    
    if params[:enzyme] && !param_blank?(params[:enzyme][:enzyme_code])
      select_conditions.push('enzyme_code IN (?)')
      condition_array.push(enzyme_add_gapfill(params[:enzyme][:enzyme_code]))
    end
    
    select_conditions.push('version_id = ?')
    condition_array.push(version_id)
    condition_array[0] = select_conditions.join(' AND ')
    return condition_array 
  end
  
end
