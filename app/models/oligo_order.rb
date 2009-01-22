class OligoOrder < ActiveRecord::Base
  require 'fastercsv'
  
  has_many :oligo_plates, :foreign_key => "oligo_order_id"
  
  def self.loadorders(synth_file)
    file_path = "#{RAILS_ROOT}/public#{synth_file}"
    file_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3]  #Row 4 contains submitted order header
    @oligo_order = self.new(:order_hdr => file_row[0]) #Column 1 is order header
    @oligo_order.save
   end
 
end