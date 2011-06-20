module ProjectsHelper
  
  def add_gene_link(name) 
    link_to_function name do |page|
      page.insert_html :bottom, :proj_gene, :partial => 'project_gene', 
                                            :locals => {:project_gene => ProjectGene.new}         
    end
  end 
  
end
