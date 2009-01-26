class Synthesis < ActiveRecord::Base
  
  def self.save_synth_order(researcher, gene, oligos)
    rownum = 0
    timestamp = Time.now
    
    # Use timestamp for created_at field, so that all records for this order can be grouped together
    for oligo in oligos do
      rownum += 1
      row = rownum.to_s
      @synthesis = self.new(:researcher => researcher, :gene_code => gene,
                            :order_line_nr => row,
                            :oligo_name => oligo["oligo_name"], 
                            :selector_useq => oligo["selector_useq"],
                            :created_at => timestamp)
      @synthesis.save
    end
  end
  
  def self.create_synth_file(oligos)
    file_path = "#{RAILS_ROOT}/public/created_file/synthesis.txt"
    f = File.new(file_path, 'w')
    rownum = 0
    for oligo in oligos do
        rownum += 1
        row = rownum.to_s
        f.write row + "\t" + oligo["oligo_name"] + "\t" + oligo["selector_useq"] + "\n"
    end
    f.close
  end
  
end
