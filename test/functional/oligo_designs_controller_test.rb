require File.dirname(__FILE__) + '/../test_helper'
require 'oligo_designs_controller'

# Re-raise errors caught by the controller
class OligoDesignsController; def rescue_action(e) raise e end; end

class OligoDesignsControllerTest < Test::Unit::TestCase

  fixtures :users, :roles_users, :roles, :oligo_designs

  def setup
    @controller = OligoDesignsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    authorize_as('admin')
  end
  
  def test_should_get_welcome
    get :welcome
    assert_response :success
  end

  def test_should_show_oligo_design
    get :show, :id => oligo_designs(:cancer10_AKT1).id
    assert_response :success
  end
  
  def test_should_get_select_params
    get :select_params
    assert_response :success
  end
  
  def test_should_redirect_to_select_params
    post :list_selected, :genes => ' '
    assert_redirected_to :action => :select_params
  end
  
  def test_should_get_list_selected
    post :list_selected, :genes => 'AKT1 TP53'
    assert_equal 'g', assigns(:rc)
    assert_template "list_selected"
  end
  
end

  
