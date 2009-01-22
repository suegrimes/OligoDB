class OligoWell < ActiveRecord::Base
  require 'fastercsv'
  
  belongs_to :oligo_design, :foreign_key => "oligo_design_id"
  belongs_to :oligo_plate, :foreign_key => "oligo_plate_id"
  
  def self.loadwells(synth_file)
    file_path  = "#{RAILS_ROOT}/public#{synth_file}"
    plate_codes = ["S", "A", "B"]
    
    #Read row 4 (array index=3) of synthesis file, which contains submitted plate nr
    submit_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3] 
    
    #split 1st column, with _ delimiter to determine plate number
    plate_dtl  = submit_row[0].split(/_/)  
    plate_nr   = [plate_dtl[0],plate_dtl[1]].join('_')
    
    #read rows 9 (array index=8) to eof, which contain details of oligo synthesis
    well_dtls = FasterCSV.read(file_path, {:col_sep => "\t"})[8..-1] 
    
    #loop through well_dtls array and create details for master plate, copy plate A, copy plate B
    well_dtls.each do |well_row|
   
      oligo_well_nr = well_row[1]
      oligo_name    = well_row[2]
      # need to return error if oligo_design is not found (write to error log?)
      oligo_design    = OligoDesign.find_by_oligo_name(oligo_name)
      oligo_design_id = oligo_design.id
 
      plate_codes.each do |copy_code|
        case copy_code
        when "S"
          # need to return error if plate nr is non-unique (find_by will return first match)
          oligo_plate = OligoPlate.find_by_oligo_plate_nr(plate_nr)
          @oligo_well  = self.new(:oligo_plate_id => oligo_plate.id,
                             :oligo_plate_nr => oligo_plate.oligo_plate_nr,
                             :oligo_name => oligo_name,
                             :oligo_design_id => oligo_design_id,
                             :oligo_well_nr => well_row[1],
                             :well_initial_volume => well_row[3],
                             :well_rem_volume => well_row[6])
          @oligo_well.save
          
        when "A"
          oligo_plate = OligoPlate.find_by_oligo_plate_nr(plate_nr + 'A')
          @oligo_well  = self.new(:oligo_plate_id => oligo_plate.id,
                             :oligo_plate_nr => oligo_plate.oligo_plate_nr,
                             :oligo_name => oligo_name,
                             :oligo_design_id => oligo_design_id,
                             :oligo_well_nr => well_row[1],
                             :well_initial_volume => well_row[4],
                             :well_rem_volume => well_row[4])
          @oligo_well.save
          
        when "B"
          oligo_plate = OligoPlate.find_by_oligo_plate_nr(plate_nr + 'B')
          @oligo_well  = self.new(:oligo_plate_id => oligo_plate.id,
                             :oligo_plate_nr => oligo_plate.oligo_plate_nr,
                             :oligo_name => oligo_name,
                             :oligo_design_id => oligo_design_id,
                             :oligo_well_nr => well_row[1],
                             :well_initial_volume => well_row[5],
                             :well_rem_volume => well_row[5])
          @oligo_well.save 
        end  #end case
  end #end plate copy do statement   
end  #end well details each statement

end  #end loadwells method

# currently not used (written for old table definitions, oligo_plates ~ oligo_wells) 
  def self.unique_plates_and_min_vol
    self.find(:all, :select => "oligo_plate_nr, min(well_rem_volume) as min_volume", 
               :group => :oligo_plate_nr)
  end
   
# currently not used (written for old table definitions, oligo_plates ~ oligo_wells)
  def self.find_plates_for_enz_with_vol(enzymes, vol)
    self.find_by_sql(["SELECT oligo_name, 
                        oligo_order_id, 
                        id AS plate_id,
                        oligo_plate_nr,
                        plate_copy_code,
                        oligo_well_nr,
                        well_rem_volume
                  FROM oligo_plates
                  WHERE (oligo_name, plate_copy_code) IN 
                    (SELECT oligo_name, min(plate_copy_code)
                     FROM oligo_plates
                     WHERE enzyme_code IN (?) AND well_rem_volume > ?
                     GROUP BY oligo_name) 
                  ORDER BY oligo_name", enzymes, vol])
  end
   
  #currently not used (written for old table definitions, oligo_plates ~ oligo_wells)
  def self.create_copy_order(source_plate, dest_plate, volume)
    oligo_plate_wells = self.find_all_by_oligo_plate_nr(source_plate)
    
    file_path = "#{RAILS_ROOT}/public/created_file/plate_copy.txt"
    f = File.new(file_path, 'w')
    for plate_well in oligo_plate_wells do
        f.write "P3 \t" + 
                plate_well["oligo_plate_nr"] + "\t" + 
                plate_well["oligo_well_nr"]  + "\t" +
                "P6 \t" +
                dest_plate                   + "\t" +
                plate_well["oligo_well_nr"]  + "\t" +
                volume + "\n"
    end
    f.close  
  end

end