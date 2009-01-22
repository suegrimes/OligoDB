require 'test_helper'

class RegionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:regions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_region
    assert_difference('Region.count') do
      post :create, :region => { }
    end

    assert_redirected_to region_path(assigns(:region))
  end

  def test_should_show_region
    get :show, :id => regions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => regions(:one).id
    assert_response :success
  end

  def test_should_update_region
    put :update, :id => regions(:one).id, :region => { }
    assert_redirected_to region_path(assigns(:region))
  end

  def test_should_destroy_region
    assert_difference('Region.count', -1) do
      delete :destroy, :id => regions(:one).id
    end

    assert_redirected_to regions_path
  end
end
