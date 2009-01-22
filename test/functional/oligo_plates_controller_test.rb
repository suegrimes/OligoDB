require 'test_helper'

class OligoPlatesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:oligo_plates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_oligo_plate
    assert_difference('OligoPlate.count') do
      post :create, :oligo_plate => { }
    end

    assert_redirected_to oligo_plate_path(assigns(:oligo_plate))
  end

  def test_should_show_oligo_plate
    get :show, :id => oligo_plates(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => oligo_plates(:one).id
    assert_response :success
  end

  def test_should_update_oligo_plate
    put :update, :id => oligo_plates(:one).id, :oligo_plate => { }
    assert_redirected_to oligo_plate_path(assigns(:oligo_plate))
  end

  def test_should_destroy_oligo_plate
    assert_difference('OligoPlate.count', -1) do
      delete :destroy, :id => oligo_plates(:one).id
    end

    assert_redirected_to oligo_plates_path
  end
end
