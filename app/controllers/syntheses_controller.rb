class SynthesesController < ApplicationController
  # GET /syntheses
  # GET /syntheses.xml
  def index
    # postgresql does not allow DESC in group by, so need to add the order by clause for sorting
    @syntheses = Synthesis.find(:all, :select => "researcher, created_at, gene_code",
                                      :group => "researcher, created_at, gene_code",
                                      :order => "researcher, created_at DESC, gene_code")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @syntheses }
    end
  end

  # GET /syntheses/1
  # GET /syntheses/1.xml
  def show
    @synthesis = Synthesis.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @synthesis }
    end
  end

def orderparams
    @gene = params[:synthesis][:gene_code]
    @researcher = params[:synthesis][:researcher]
    
    @oligos = OligoDesign.find(:all, :conditions => ["gene_code = ?", @gene],
                            :select => "oligo_name, selector_useq")                        

    respond_to do |format|
      format.html # orderparams.html.erb
      format.xml  { render :xml => @synthesis }
    end
  end

  # GET /syntheses/new
  # GET /syntheses/new.xml
  def new
    @synthesis = Synthesis.new
    @rnames = Researcher.find(:all, :order=>"researcher_name")
    @genes = OligoDesign.unique_genes

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @synthesis }
    end
  end

  # GET /syntheses/1/edit
  def edit
    @synthesis = Synthesis.find(params[:id])
  end
  
  # POST /syntheses
  # POST /syntheses.xml
  def create
    @gene = params[:gene]             # scalar
    @researcher = params[:researcher] # scalar
    @oligos = params[:oligo]  # array of hashes {:oligo_name, :selector_useq}
    
    Synthesis.save_synth_order(@researcher, @gene, @oligos) #save oligo order lines to table
    Synthesis.create_synth_file(@oligos) #write flat file for order synthesis                       

     respond_to do |format|
       flash[:notice] = 'Synthesis order was successfully created.'
       format.html { redirect_to(syntheses_url)}
       format.xml  { render :xml => @synthesis, :status => :created, :location => @synthesis }
     end
  end

  # PUT /syntheses/1
  # PUT /syntheses/1.xml
  def update
    @synthesis = Synthesis.find(params[:id])

    respond_to do |format|
      if @synthesis.update_attributes(params[:synthesis])
        flash[:notice] = 'Synthesis was successfully updated.'
        format.html { redirect_to(@synthesis) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @synthesis.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /syntheses/1
  # DELETE /syntheses/1.xml
  def destroy
    @synthesis = Synthesis.find(params[:id])
    @synthesis.destroy

    respond_to do |format|
      format.html { redirect_to(syntheses_url) }
      format.xml  { head :ok }
    end
  end
end
