require 'test_helper'

class AliquotsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:aliquots)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_aliquot
    assert_difference('Aliquot.count') do
      post :create, :aliquot => { }
    end

    assert_redirected_to aliquot_path(assigns(:aliquot))
  end

  def test_should_show_aliquot
    get :show, :id => aliquots(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => aliquots(:one).id
    assert_response :success
  end

  def test_should_update_aliquot
    put :update, :id => aliquots(:one).id, :aliquot => { }
    assert_redirected_to aliquot_path(assigns(:aliquot))
  end

  def test_should_destroy_aliquot
    assert_difference('Aliquot.count', -1) do
      delete :destroy, :id => aliquots(:one).id
    end

    assert_redirected_to aliquots_path
  end
end
