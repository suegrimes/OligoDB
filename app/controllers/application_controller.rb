# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem
  include OligoExtensions

  before_filter :login_required
  
  require 'fastercsv'
  require 'ar-extensions/adapters/mysql'
  require 'ar-extensions/import/mysql'
  
  helper :all # include all helpers, all the time
  
  # Structure used for converting array into class with label/value pairs, for collection_select
  LabelValue = Struct.new(:label, :value)
 
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '01ace71a5cf310fe9f1ee1867cd1da7b'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
  
  def store_comment(model_instance, params)
    comment = Comment.create(:user_id => current_user.id, 
                             :title => params[:title], 
                             :comment => params[:comment])
    model_instance.add_comment(comment) 
  end

  def create_array_from_text_area(text, ret_type='text')
    if text.blank? 
      return []
    else
      param_list = (text.gsub(',', ' ')).split
      param_list.pop if param_list.last =~ /^\s*$/
    end  
    
    param_list.collect! { |value| value.to_i} if ret_type == 'integer'
    return param_list
  end
   
  def param_blank?(val)
    if val.nil?
      val_blank = true
    elsif val.is_a? Array
      val_blank = (val.length == 1 && val[0].blank? ? true : false )
    else
       val_blank = val.blank?
    end
    return val_blank 
  end
  
  def check_if_blank(model_object, model_text, param_type)
    if model_object.nil? || model_object.empty?
      error_found = true
      param_desc = param_decode(param_type)
      flash[:notice] = "No #{model_text} found for #{param_desc} entered - please try again"
    else
      error_found = false
    end
    
    return error_found
  end
  
  def param_decode(param_type)
    case param_type
      when 'id'
        return 'ids'
      when 'gt'
        return 'genes'
      when 'gl'
        return 'genes'
      when 'p'
        return 'project'
      else
        return 'parameters'
    end
  end
  
  def enzyme_add_gapfill(enzymes)
    enz_wgapfill = []
    enzymes.each do |enzyme|
      enz_wgapfill.push(enzyme)
      enz_wgapfill.push(enzyme + '_gapfill') #if enzyme !=~ /.*_gapfill/     
    end
    return enz_wgapfill
  end
  
end
