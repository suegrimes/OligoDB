require 'test_helper'

class OligoDesignTest < ActiveSupport::TestCase
  fixtures :oligo_designs, :versions
  
  # Dummy test to validate test environment/setup
  def test_truth
    assert true
  end
  
  def test_dup_oligo
    dup_oligo_name = oligo_designs(:cancer10_AKT1).oligo_name
    oligo_design   = OligoDesign.new(:oligo_name => dup_oligo_name)
    assert !oligo_design.save
  end
  
  def test_polarity
    oligo_design = oligo_designs(:cancer10_AKT1)
    assert_equal oligo_design.polarity, 'plus'
    
    oligo_design = oligo_designs(:pancreatic_TP53)
    assert_equal oligo_design.polarity, 'minus'
  end
  
  def test_find_oligo_name
    oligo_design = OligoDesign.find_using_oligo_name_id(oligo_designs(:cancer10_AKT1).oligo_name)
    assert_equal oligo_design.id, oligo_designs(:cancer10_AKT1).id
    
    oligo_design = OligoDesign.find_using_oligo_name_id(oligo_designs(:pancreatic_TP53).oligo_name)
    assert_equal oligo_design.id, oligo_designs(:pancreatic_TP53).id
  end
  
  def test_find_selectors_from_gene_list
    oligo_designs = OligoDesign.find_selectors_from_gene_list(['AKT1', 'TP53'])
    assert_equal 1, oligo_designs.size
  end
  
  def test_selector_not_found_from_gene_list
    oligo_designs = OligoDesign.find_selectors_from_gene_list(['XYZ'])
    assert_equal [], oligo_designs
  end
end
