# == Schema Information
#
# Table name: oligo_orders
#
#  id              :integer(4)      not null, primary key
#  order_hdr       :string(25)
#  researcher      :string(20)
#  order_submit_dt :date
#  order_hdr_recv  :string(25)
#  order_recv_dt   :date
#  created_at      :datetime
#  updated_at      :datetime
#

class OligoOrder < InventoryDB
  
  has_many :oligo_plates, :foreign_key => "oligo_order_id"
  
  def self.loadorders(file_path)
    $oligo_order_id = nil
    
    #Read row 4 (array index 3) of synthesis file, which contains submitted order header
    begin
    file_row = FasterCSV.read(file_path, {:col_sep => "\t"})[3]
    
    #Order header received from synthesis is column 1 (array index 0) of the row read above
    oligo_order = self.find_or_create_by_order_hdr_recv(file_row[0]) 
    $oligo_order_id = oligo_order.id
    return 0
    
    rescue FasterCSV::MalformedCSVError
      return -2
    rescue
      return -5
    end
  end #end of method
  
end #end of class
