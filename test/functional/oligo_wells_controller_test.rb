require 'test_helper'

class OligoWellsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:oligo_wells)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_oligo_well
    assert_difference('OligoWell.count') do
      post :create, :oligo_well => { }
    end

    assert_redirected_to oligo_well_path(assigns(:oligo_well))
  end

  def test_should_show_oligo_well
    get :show, :id => oligo_wells(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => oligo_wells(:one).id
    assert_response :success
  end

  def test_should_update_oligo_well
    put :update, :id => oligo_wells(:one).id, :oligo_well => { }
    assert_redirected_to oligo_well_path(assigns(:oligo_well))
  end

  def test_should_destroy_oligo_well
    assert_difference('OligoWell.count', -1) do
      delete :destroy, :id => oligo_wells(:one).id
    end

    assert_redirected_to oligo_wells_path
  end
end
