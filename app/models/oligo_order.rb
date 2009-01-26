class OligoOrder < ActiveRecord::Base
  require 'fastercsv'
  
  has_many :oligo_plates, :foreign_key => "oligo_order_id"
  
  def self.loadorders(synth_file)
    file_path = "#{RAILS_ROOT}/public#{synth_file}"
    $oligo_order_id = nil
    
    #Read row 4 (array index 3) of synthesis file, which contains submitted order header
    file_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3]
    
    #Order header received from synthesis is column 1 (array index 0) of the row read above
    oligo_order = self.find_or_create_by_order_hdr_recv(file_row[0]) 
    $oligo_order_id = oligo_order.id
   end
 
end