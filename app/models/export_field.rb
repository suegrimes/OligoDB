# == Schema Information
#
# Table name: export_fields
#
#  id           :integer(11)     not null, primary key
#  export_type  :integer(4)
#  model_nm     :string(50)      default(""), not null
#  report_order :integer(6)
#  fld_heading  :string(25)
#  fld_name     :string(50)
#

class ExportField < ActiveRecord::Base

def self.headings(rptfmt=1)
  rpt_hdgs = self.find(:all, :order => :report_order, :conditions => ['export_type = ?', rptfmt])
  rpt_hdgs.collect(&:fld_heading)  
end

def self.fld_names(rptfmt=1)
  rpt_flds = self.find(:all, :order => :report_order, :conditions => ['export_type = ?', rptfmt])
  rpt_flds.collect{|xport| [xport.model_nm, xport.fld_name]}
end

end
