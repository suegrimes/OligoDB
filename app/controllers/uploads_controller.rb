class UploadsController < ApplicationController
include AuthenticatedSystem
  # GET /uploads
  # GET /uploads.xml
  def index
    @filetype = params[:filetype]
    @uploads = Upload.find(:all, :order => "created_at DESC",
                           :conditions => ["content_type = ?", @filetype])
                           

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @uploads }
    end
  end
 
  # GET /uploads/1
  # GET /uploads/1.xml
  def show
    @upload = Upload.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @upload }
    end
  end 
  
  # GET /uploads/new
  # GET /uploads/new.xml
  def new
    @upload = Upload.new
    @filetype = params[:filetype]
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @upload }
    end
  end

  def create
    @upload = Upload.new(params[:upload])
    @filetype = params[:upload][:content_type]

    respond_to do |format|
      if @upload.save
        flash[:notice] = 'File successfully updated.'
        format.html { redirect_to :action => "index", :filetype => @filetype}
        format.xml  { render :xml => @upload, :status => :created, :location => @upload }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @upload.errors, :status => :unprocessable_entity }
      end
    end
  end

  def loadtodb
    @filetype = params[:filetype]
    upload = Upload.find(params[:id]) 
    @filename = upload.upload_file
  
    # use case statement to redirect to appropriate controller?
    # or need to figure out a way to pass @save_cnt parameter back (across classes)
    case @filetype
      when "Design"
        OligoDesign.loaddesigns(@filename)
        flash[:notice] = 'Oligo design file loaded'
      when "Synthesis"
        OligoOrder.loadorders(@filename)
        OligoPlate.loadplates(@filename)
        OligoWell.loadwells(@filename)
        flash[:notice] = 'Oligo synthesis plates loaded'
      when "Aliquot"
        Aliquot.loadaliquots(@filename)
        flash[:notice] = 'BioMec table loaded'
      else
        flash[:notice] = 'Invalid content type for file load to db'
    end
  end
  
end