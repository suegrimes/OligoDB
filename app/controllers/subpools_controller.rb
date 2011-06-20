class SubpoolsController < ApplicationController
  def index
    @subpools = Subpool.find(:all, :include => [:pool, :pool_well],
                             :order => 'pools.pool_name, pool_wells.description, pool_wells.pool_plate_nr, pool_wells.pool_well_nr')
  end
  
  def show
    @subpool = Subpool.find(params[:id])
  end
  
  def show_dtls
    @condition_array = []
    if params[:subpool_id]
      @condition_array = ["subpools.id = ?", params[:subpool_id]]
      @subpool = Subpool.find(params[:subpool_id], :include => [:pool, :pool_well] )
      well_descr = (@subpool.pool_well.description.blank? ? "BioMek well id: #{@subpool.pool_well.id}" : @subpool.pool_well.description)
      @subpool_name = [@subpool.pool.pool_name, well_descr].join("/")
      
    elsif params[:pool_id]
      @condition_array = ["subpools.pool_id = ?", params[:pool_id]]
      @pool = Pool.find(params[:pool_id])
      @pool_name = @pool.pool_name
    end
    
    @subpools = Subpool.find_all_with_dtls(@condition_array) 
    
    @nr_oligos = 0
    @subpools.each { |subpool| @nr_oligos += subpool.pool_well.nr_oligos }
                      
    if @subpools.empty? || @subpools.nil?
      flash[:notice] = "No oligos found for pool id #{params[:pool_id]}"
    end
    
    render :action => 'show_dtls'
  end
  
  def export_pool
    export_type = 'T'
    pool_name = 'NA'
    @subpools = Subpool.find_all_with_dtls(["subpools.id IN (?)", params[:export_id]])
    
    if params[:pool_id]
      pool = Pool.find(params[:pool_id])
      file_basename = ["pool", pool.pool_name, Date.today.to_s].join("_")
      pool_name = pool.pool_name
      
    elsif params[:subpool_id]
      subpool = Subpool.find(params[:subpool_id], :include => :pool_well)  
      if subpool.pool_well.description.blank?
        file_basename = ["biomek", subpool.pool_well.pool_plate_nr, subpool.pool_well.pool_well_nr, Date.today.to_s].join("_")
      else
        file_basename = ["subpool", subpool.pool_well.description, Data.today.to_s].join("_")
      end
      
    else
      file_basename = ["pool_dtls", Date.today.to_s].join("_")
    end
    
    case export_type
      when 'T'  # Export to tab-delimited text using csv_string
        @filename = file_basename + ".txt"
        csv_string = export_subpools_csv(@subpools, pool_name)
        send_data(csv_string,
          :type => 'text/csv; charset=utf-8; header=present',
          :filename => @filename, :disposition => 'attachment')
        
#      when 'E'  # Export to Excel using export_pool.html
#        @filename = file_basename + ".xls"
#        headers['Content-Type']="application/vnd.ms-excel"
#        headers['Content-Disposition']="attachment;filename=\"" + @filename + "\""
#        headers['Cache-Control'] = ''
#        render :action => :export_pool, :layout => false  
#      
      else # Use for debugging
        csv_string = export_subpools_csv(@subpools, pool_name)
        render :text => csv_string
      end
  end
  
  def edit
    @subpool = Subpool.find(params[:id], :include => [:pool, :pool_well])
  end

  def edit_multi
    @subpools = Subpool.find(:all, :include => [:pool, :pool_well],
                             :order => 'pools.pool_name, pool_wells.description, pool_wells.pool_plate_nr, pool_wells.pool_well_nr')
  end
  
  def update
    @subpool = Subpool.find(params[:id])

    if @subpool.update_attributes(params[:subpool])
      flash[:notice] = 'SubPool was successfully updated.'
      redirect_to(subpools_url)
    else
      render :action => "edit" 
    end
  end
  
  def upd_multi
    #subpool[0] is key (id), subpool[1] is attribute hash
    #only generate SQL update statement if oligo concentration was entered
    params[:subpool].each do |subpool|
      Subpool.update(subpool[0], subpool[1]) if !subpool[1][:oligo_conc_nm].blank?
    end

    flash[:notice] = 'Subpool(s) successfully updated'
    redirect_to(subpools_url)
#     render :action => :debug
  end
  
  def upd_conc
    Subpool.upd_oligo_conc(params[:pool_id])
    flash[:notice] = "Subpool concentrations updated"
    redirect_to pool_path(params[:pool_id])
  end
  
protected
  def export_subpools_csv(subpools, pool_name)
    headings = %w{Date Pool Subpool ConcInPool OligoName Chromosome Gene Enzyme
                  AmplLength Polarity SelectorSeq Selector5Prime Selector3Prime
                  AmpliconStart AmpliconEnd AmpliconSeq AnnotationFlags OtherAnnot VersionID GenomeBuild
                  SourcePlate SourceWell ulToBioMek BioMekRun BioMekWell}
                  
    flds     = [['pw', 'description' ], 
                ['sp', 'oligo_conc_nm'],
                ['ow', 'oligo_name'],
                ['so', 'chromosome_nr'],
                ['so', 'gene_code'],
                ['so', 'enzyme_code'],
                ['so', 'amplicon_length'],
                ['so', 'sel_polarity'],
                ['so', 'selector_useq'],
                ['so', 'usel_5prime'],
                ['so', 'usel_3prime'],
                ['so', 'amplicon_chr_start_pos'],
                ['so', 'amplicon_chr_end_pos'],
                ['so', 'amplicon_seq'],
                ['so', 'annotation_codes'],
                ['so', 'other_annotations'],
                ['so', 'version_id'],
                ['so', 'genome_build'],
                ['aq', 'plate_from'],
                ['aq', 'well_from'],
                ['aq', 'volume_pipetted'],
                ['aq', 'plate_to'],
                ['aq', 'well_to']]
    
    csv_string = FasterCSV.generate(:col_sep => "\t") do |csv|
      csv << headings
   
      subpools.each do |subpool|
        subpool.pool_well.aliquots.each do |aliquot| 
          fld_array = []
        
          flds.each do |obj_string, fld|
            obj = case obj_string
              when 'so'; aliquot.oligo_well.synth_oligo
              when 'ow'; aliquot.oligo_well
              when 'pw'; subpool.pool_well
              when 'sp'; subpool
              else aliquot
            end
          
            fld_array << obj.send(fld)
          end
        
         csv << [Date.today.to_s, pool_name].concat(fld_array)
       end
      end
    end
    return csv_string
  end

end
