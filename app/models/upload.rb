# == Schema Information
#
# Table name: uploads
#
#  id                :integer(11)     not null, primary key
#  title             :string(255)
#  body              :text
#  filename          :string(255)
#  original_filename :string(255)
#  content_type      :string(255)
#  version_id        :integer(11)
#  size              :integer(11)
#  upload_file       :string(255)
#  sender            :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  loadtodb_at       :datetime
#

class Upload < ActiveRecord::Base
  # default directory for upload_column is RAILS_ROOT/public => go up two directories from default
  upload_column :upload_file, :store_dir => File.join("..", "..", "OligoFiles", "upload_file"),
                              :extensions => %w(txt csv)
  validates_presence_of :upload_file, :content_type
  validates_presence_of :version_id,   :if => Proc.new {|v| v.content_type == 'Design'}
  validates_integrity_of :upload_file, :message => "file must be tab-delimited text of type .txt or .csv"
  
  FILES_ROOT = (CAPISTRANO_DEPLOY == true ? File.join(RAILS_ROOT, "..", "..", "shared", "upload_file") :
                                            File.join(RAILS_ROOT, "..", "OligoFiles", "upload_file"))
  
  def self.listfile(id)
    uploadfile = self.find(id)
    upload_path = uploadfile.existing_file_path
    return ["ERROR - File #{upload_path} not found"] if !FileTest.file?(upload_path)
   
    f = File.open(upload_path, 'r')
    @filelines = Array.new
    f.readlines.each do |line|
      @filelines << line.split("\t")
    end 
    
    return @filelines
  end
  
  def file_name_no_dir
    # Return last component of file directory/name string
    return upload_file.to_s.split('/')[-1]
  end
  
  def existing_file_path
    File.join(FILES_ROOT, file_name_no_dir)
  end
  
  def self.new_file_path(file_name_with_ext)
    File.join(FILES_ROOT, file_name_with_ext)
  end
end
