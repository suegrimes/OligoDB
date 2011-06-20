class ProjectsController < ApplicationController
  require_role "stanford", :for_all_except => [:index, :show]
  before_filter :dropdowns, :only => [:new, :edit]
  
  # GET /projects
  def index
    @projects = Project.find(:all)
  end

  # GET /projects/1
  def show
    @project = Project.find_by_id(params[:id], :include => :project_genes,
                                               :order => 'project_genes.gene_code')
  end

  # GET /projects/new
  def new
    @project = Project.new(:version_id => Version::DESIGN_VERSION_ID)
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find_by_id(params[:id], :include => :project_genes,
                                               :order => 'project_genes.gene_code')
  end

  # POST /projects
  def create
    @project = Project.new(params[:project])

    if @project.save
      flash[:notice] = 'Project was successfully created'
      render :action => "addgenes" 
    else
      render :action => "new" 
    end
  end
  
  def addgenes 
  end
  
  def savegenes
    # check for gene parameters entered (cannot be nil/blank)
    if (params[:genes].empty? || params[:genes] =~ /^\s*$/)
      flash[:notice] = 'Please select one or more genes for this project'
      render :action => 'addgenes'
    else
      @project = Project.find(params[:project_id])
      @gene_list  = params[:genes].split
      @save_cnt = ProjectGene.add_genes(params[:project_id],@gene_list)
      flash[:notice] = "#{@save_cnt} genes added for project: #{@project.project_name}"
      redirect_to :action => 'index'  
    end 
    
  end

  # PUT /projects/1
  def update
    params[:project][:existing_gene_attributes] ||= {} 
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to(@project) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /projects/1
  def destroy
    @project = Project.find(params[:id])
    @project.delete_incl_children 
    redirect_to(projects_url) 
  end
  
private
  def dropdowns
    @versions = Version.find(:all)
  end
end
