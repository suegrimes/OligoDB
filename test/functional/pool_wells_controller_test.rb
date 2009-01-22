require 'test_helper'

class PoolWellsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:pool_wells)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_pool_well
    assert_difference('PoolWell.count') do
      post :create, :pool_well => { }
    end

    assert_redirected_to pool_well_path(assigns(:pool_well))
  end

  def test_should_show_pool_well
    get :show, :id => pool_wells(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => pool_wells(:one).id
    assert_response :success
  end

  def test_should_update_pool_well
    put :update, :id => pool_wells(:one).id, :pool_well => { }
    assert_redirected_to pool_well_path(assigns(:pool_well))
  end

  def test_should_destroy_pool_well
    assert_difference('PoolWell.count', -1) do
      delete :destroy, :id => pool_wells(:one).id
    end

    assert_redirected_to pool_wells_path
  end
end
