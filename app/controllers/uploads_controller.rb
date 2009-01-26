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
        flash[:notice] = 'File successfully uploaded.'
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
        flash.now[:notice] = 'Oligo design file: ' + $rec_loaded.to_s + ' designs loaded, ' + 
                                $rec_rejected.to_s + ' duplicate oligos ignored'
      when "Synthesis"
        OligoOrder.loadorders(@filename)
        OligoPlate.loadplates(@filename, $oligo_order_id)
#        flash.now[:notice] = $rec_loaded.to_s + ' new oligo synthesis plates loaded, ' + 
#                             $rec_rejected.to_s + ' plates unable to save'
        plates_created = $rec_loaded
        OligoWell.loadwells(@filename)
        flash.now[:notice] = plates_created.to_s + ' new oligo synthesis plates loaded, ' + 
                         $rec_loaded.to_s + ' new wells loaded, ' + $rec_rejected.to_s +
                        ' duplicate wells ignored'
      when "Aliquot"
        Aliquot.loadaliquots(@filename)
        flash.now[:notice] = 'BioMec data: ' + $rec_loaded.to_s + ' plate/wells loaded, ' +
                              $rec_rejected.to_s + ' duplicate plate/wells ignored'
      else
        flash.now[:notice] = 'Invalid content type for file load to database'
    end
  end
  
end