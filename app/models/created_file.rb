# == Schema Information
#
# Table name: created_files
#
#  id            :integer(11)     not null, primary key
#  content_type  :string(20)      default(""), not null
#  created_file  :string(255)     default(""), not null
#  researcher_id :integer(11)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

class CreatedFile < ActiveRecord::Base
  belongs_to :researcher, :foreign_key => "researcher_id"
  
  FILES_ROOT = File.join(RAILS_ROOT, "..", "OligoFiles", "created_file")
  
  def self.list_all_by_content(content_type)
    self.find_all_by_content_type(content_type,
                     :include => :researcher,
                     :order => "created_at DESC")
  end
  
  def self.listfile(id)
    crfile_path = self.existing_file_path(id)
    return ["ERROR - File not found"]  if !FileTest.file?(crfile_path)
    
    f = File.open(crfile_path, 'r')

    @filelines = Array.new
    f.readlines.each do |line|
      @filelines << line.split("\t")
    end 
    
    return @filelines
  end
  
  def file_path
    File.join(FILES_ROOT, "#{created_file}.txt")
  end
  
  def self.existing_file_path(id)
    createdfile = self.find(id)
    File.join(FILES_ROOT, "#{createdfile.created_file}.txt")
  end
  
  def self.new_file_path(file_name)
    File.join(FILES_ROOT, "#{file_name}.txt")
  end
  
end
