#read App_Versions file to set current application version #
#version# is first row, first column
filepath = "#{RAILS_ROOT}/public/app_versions.txt"

if FileTest.file?(filepath)
  version_firstrow = FasterCSV.read(filepath, {:col_sep => "\t"})[0]
  APP_VERSION = version_firstrow[0]
end 

CAPISTRANO_DEPLOY = RAILS_ROOT.include?('releases')

