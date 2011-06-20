class UploadsController < ApplicationController
  require_role "stanford"

  # GET /uploads
  def index
    @filetype ||= params[:filetype]
    @uploads = Upload.find(:all, :order => "created_at DESC",
                           :conditions => ["content_type = ?", @filetype]) 
    @version_id = (@uploads.empty? ? 0 : @uploads[0].version_id)
    render :action => 'index'
  end
 
  # GET /uploads/1
  def show
    @upload = Upload.find(params[:id])
  end 
  
  # GET /uploads/new
  def new
    @upload = Upload.new
    @filetype = params[:filetype]
    @versions = Version.find(:all)
  end

  def create
    @upload = Upload.new(params[:upload])
    @filetype = params[:upload][:content_type]
    
    if @upload.save
      flash[:notice] = 'File successfully uploaded.'
      redirect_to :action => 'index', :filetype => @filetype
    else
      flash.now[:notice] = 'Error uploading file - please correct any errors listed below'
      @versions = Version.find(:all)
      render :action => 'new' 
    end
  end
  
  def show_files
    @upload_file = Upload.listfile(params[:id])
    @filetype = params[:filetype]
  end

  # DELETE /uploads/1
  def destroy
    @upload = Upload.find(params[:id])
    @file_name = @upload.file_name_no_dir
    @file_path = @upload.existing_file_path
    
    # delete file from file system
    File.delete(@file_path) if FileTest.exist?(@file_path)
    
    # delete file entry from SQL uploads table
    @upload.destroy
    redirect_to :action => 'index', :filetype => @upload.content_type
  end

  def loadtodb
    @filetype = params[:filetype]
    upload    = Upload.find(params[:id]) 
    @file_name = upload.file_name_no_dir
    @file_path = upload.existing_file_path
    rc = $rec_loaded = $rec_rejected = 0
    
    if !FileTest.file?(@file_path)
      display_msg(-1, @file_name, @filetype, 0)
      return
    end
    
    # execute appropriate model method, based on value of @filetype
    case @filetype
      when 'Design'
        rc = PilotOligoDesign.loaddesigns(@file_path, upload.version_id)
        display_msg(rc, @file_name, @filetype, 0)
 
      when 'Synthesis'
        rc = SynthOligo.loadoligos(@file_path)
        if rc == 0
          rc = OligoOrder.loadorders(@file_path)
        end
        if rc == 0
          rc = OligoPlate.loadplates(@file_path, $oligo_order_id)
          plates_created = $rec_loaded
        end
        if rc == 0
          rc = OligoWell.loadwells(@file_path)
        end
        display_msg(rc, @file_name, @filetype, plates_created)

      when 'BioMek'
        rc = Aliquot.loadaliquots(@file_path)
        display_msg(rc, @file_name, @filetype, 0)
        
      else
        flash.now[:notice] = 'Invalid content type for file load to database'
    end
    
    # update database load date/time 
    if $rec_loaded > 0 then
      upload.update_attribute(:loadtodb_at, Time.now)
    end 
  end
  
  def display_msg (rc, filename, filetype, plates_created)
    case rc
      when 0
        case filetype
          when 'Design'
            error_msg = ($rec_rejected > 0 ? ", #{$rec_rejected.to_s} duplicate oligos ignored" : " ")
            flash.now[:notice] = "Oligo design file: #{$rec_loaded.to_s} designs loaded#{error_msg}"
          when 'Synthesis'
            error_msg = ($rec_rejected > 0 ? ", #{$rec_rejected.to_s} duplicate wells ignored" : " ")
            flash.now[:notice] = "Synthesis: #{plates_created.to_s} oligo synthesis plates loaded#{error_msg}" 
          when 'BioMek'
            error_msg = ($rec_rejected > 0 ? ", #{$rec_rejected.to_s} errors" : " ")
            flash.now[:notice] = "BioMek: #{$rec_loaded.to_s} plate/wells loaded#{error_msg}"
          end
        when -1
          flash.now[:notice] = "ERROR - File: #{filename} does not exist, or is not a regular file"
        when -2
          flash.now[:notice] = "ERROR - File: #{filename} is not a valid CSV file"
        when -3
          flash.now[:notice] = "ERROR - File: #{filename} contains insufficient columns"
        when -4
          if filetype == 'BioMek'
              flash.now[:notice] = "ERROR - File: #{filename} contains one or more invalid source plates/wells"
          else
              flash.now[:notice] = "ERROR - File: #{filename} contains one or more invalid #{filetype} records"
          end
        when -5
          flash.now[:notice]     = "ERROR - File: #{filename} load unsuccessful - check file column format"
        when -6
          flash.now[:notice]     = "ERROR - File: #{filename} load unsuccessful - incorrect column headers"
        else
          flash.now[:notice]     = "ERROR - File: #{filename} load unsuccessful - return code #{rc}"
      end     
  end
  
  def help
    @filetype = params[:filetype]
    case @filetype
      when 'Design'
        format.html {redirect_to :controller=>'help', :action=>'oligodesign'}
      when 'Synthesis'
        format.html {redirect_to :controller=>'help', :action=>'oligosynthesis'}
      when 'BioMek'
        format.html {redirect_to :controller=>'help', :action=>'biomekfile'}
      else
        flash.now[:notice] = 'Unknown file type - no help found'
    end
  end
  
end