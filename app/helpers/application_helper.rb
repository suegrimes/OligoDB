# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def menu_display
    display_menu = {}
    Indicator::MENU_MAPPING.each do |menu_key, app_controllers|
      display_menu[menu_key.to_sym] = (app_controllers.include?(controller.controller_name) ? 1 : 0)
    end
    return display_menu     
  end
  
  def toggle_div(div)
    update_page { |page| page[div].toggle }
  end
  
  def version_name(version_id)
    vname = Version::BUILD_VERSION_NAMES.assoc(version_id.to_i)
    return (vname ? [vname[0], vname[1]].join('-') : 'invalid')
  end
  
  def format_annot(qc=nil, annot=nil)
    if qc.blank? && annot.blank?
      annot_val = ' '
    elsif annot.blank?
      annot_val = qc 
    else
      annot_val = [qc, annot].join('/')
    end
    return annot_val
  end

# Following methods also exist in /lib/oligo_extensions.rb - so should be able to delete from here
#
#  def curr_oligo_format?(oligo_name)
#    #Design versions < 3, have oligo names which do NOT have an id# which matches the id primary key.
#    #  These versions have an oligo name with 5 components, with gene code in 3rd position, unless
#    #  enzyme code contains 'gapfill' in which case gene is in the 4th position
#
#    #Design versions >= 3, have oligo_names which DO include an id# which matches the id primary key.
#    #  These versions have an oligo name with 8 components, with gene code in 5th position.  
#
#    #Use count of '_' delimiters to determine which format oligo name has been passed in
#    (oligo_name.count("_") > 7 ? true : false)
#  end
#  
#  def get_gene_from_oligo_name(oligo_name, curr_format=nil)
#    curr_format ||= curr_oligo_format?(oligo_name)
#    
#    if curr_format
#      # new format.  allow for possibility of gene containing one or more '_' delimiters
#      # first split oligo_name into two components using '_ROI_' delimiter
#      # gene will be the remaining substring starting after the 4th delimiter,
#      # in the first array element
#      oligo_array1 = oligo_name.split(/_ROI_/)
#      oligo_array2 = oligo_array1[0].split(/_/)
#      gene_code    = oligo_array2[4..-1].join("_")   
#    else
#      # old format.  if enzyme code is in format 'enzyme_gapfill' then gene is 4th element in
#      # array, otherwise 3rd element
#      oligo_array = oligo_name.split(/_/)
#      gene_code = (oligo_array[2] == 'gapfill' ? oligo_array[3] : oligo_array[2])
#    end
#    
#    return gene_code
#  end
#  
end
