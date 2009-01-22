require 'test_helper'

class OligoDesignsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:oligo_designs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_oligo_design
    assert_difference('OligoDesign.count') do
      post :create, :oligo_design => { }
    end

    assert_redirected_to oligo_design_path(assigns(:oligo_design))
  end

  def test_should_show_oligo_design
    get :show, :id => oligo_designs(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => oligo_designs(:one).id
    assert_response :success
  end

  def test_should_update_oligo_design
    put :update, :id => oligo_designs(:one).id, :oligo_design => { }
    assert_redirected_to oligo_design_path(assigns(:oligo_design))
  end

  def test_should_destroy_oligo_design
    assert_difference('OligoDesign.count', -1) do
      delete :destroy, :id => oligo_designs(:one).id
    end

    assert_redirected_to oligo_designs_path
  end
end
