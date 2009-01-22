class OligoDesignsController < ApplicationController
  def welcome
  end
  
  # GET /oligo_designs
  # GET /oligo_designs.xml
  def index
    @oligo_designs = OligoDesign.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @oligo_designs }
    end
  end
  
  # GET /oligo_designs/1
  # GET /oligo_designs/1.xml
  def show
    @oligo_design = OligoDesign.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @oligo_design }
    end
  end
  
  # GET /oligo_designs/new
  # GET /oligo_designs/new.xml
  def new
    @oligo_design = OligoDesign.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @oligo_design }
    end
  end

  
  # GET /oligo_designs/1/edit
  def edit
    @oligo_design = OligoDesign.find(params[:id])
  end
  
  # PUT /oligo_designs/1
  # PUT /oligo_designs/1.xml
  def update
    @oligo_design = OligoDesign.find(params[:id])

    respond_to do |format|
      if @oligo_design.update_attributes(params[:oligo_design])
        flash[:notice] = 'Oligo design was successfully updated.'
        format.html { redirect_to(@oligo_design) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @oligo_design.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # POST /oligo_designs
  # POST /oligo_designs.xml
  def create
    @oligo_design = OligoDesign.new(params[:oligo_design])

    respond_to do |format|
      if @oligo_design.save
        flash[:notice] = 'Oligo design was successfully created.'
        format.html { redirect_to(@oligo_design) }
        format.xml  { render :xml => @oligo_design, :status => :created, :location => @oligo_design }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @oligo_design.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def select_gene
    @genes = OligoDesign.unique_genes
  end
   
  def list_selected
    gene = params[:oligo_design][:gene]  # returns gene array from multiple select
    @oligo_designs = OligoDesign.find(:all, :conditions => ["gene_code IN (?)", gene])
        
      respond_to do |format|
      format.html { render :action => "index"}
      format.xml  { render :xml => @oligo_designs }
    end
  end
 
 end 
