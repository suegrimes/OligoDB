require 'test_helper'

class SynthesesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:syntheses)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_synthesis
    assert_difference('Synthesis.count') do
      post :create, :synthesis => { }
    end

    assert_redirected_to synthesis_path(assigns(:synthesis))
  end

  def test_should_show_synthesis
    get :show, :id => syntheses(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => syntheses(:one).id
    assert_response :success
  end

  def test_should_update_synthesis
    put :update, :id => syntheses(:one).id, :synthesis => { }
    assert_redirected_to synthesis_path(assigns(:synthesis))
  end

  def test_should_destroy_synthesis
    assert_difference('Synthesis.count', -1) do
      delete :destroy, :id => syntheses(:one).id
    end

    assert_redirected_to syntheses_path
  end
end
