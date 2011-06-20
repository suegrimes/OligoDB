class HelpController < ApplicationController
  def overview
  end
  
  def index
    @filetype = params[:filetype]
 
    case @filetype
      when "Design"
        redirect_to :action=>'oligodesign'
      when "Synthesis"
        redirect_to :action=>'oligosynthesis'
      when "BioMek"
        redirect_to :action=>'biomekfile'
      else
        format.html #index.html.erb
    end
  end
  
  def oligodesign
  end
  
  def oligosynthesis
  end

  def biomekfile
  end

end
