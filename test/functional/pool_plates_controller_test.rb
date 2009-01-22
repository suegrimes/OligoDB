require 'test_helper'

class PoolPlatesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:pool_plates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_pool_plate
    assert_difference('PoolPlate.count') do
      post :create, :pool_plate => { }
    end

    assert_redirected_to pool_plate_path(assigns(:pool_plate))
  end

  def test_should_show_pool_plate
    get :show, :id => pool_plates(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => pool_plates(:one).id
    assert_response :success
  end

  def test_should_update_pool_plate
    put :update, :id => pool_plates(:one).id, :pool_plate => { }
    assert_redirected_to pool_plate_path(assigns(:pool_plate))
  end

  def test_should_destroy_pool_plate
    assert_difference('PoolPlate.count', -1) do
      delete :destroy, :id => pool_plates(:one).id
    end

    assert_redirected_to pool_plates_path
  end
end
