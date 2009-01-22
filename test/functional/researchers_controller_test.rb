require 'test_helper'

class ResearchersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:researchers)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_researcher
    assert_difference('Researcher.count') do
      post :create, :researcher => { }
    end

    assert_redirected_to researcher_path(assigns(:researcher))
  end

  def test_should_show_researcher
    get :show, :id => researchers(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => researchers(:one).id
    assert_response :success
  end

  def test_should_update_researcher
    put :update, :id => researchers(:one).id, :researcher => { }
    assert_redirected_to researcher_path(assigns(:researcher))
  end

  def test_should_destroy_researcher
    assert_difference('Researcher.count', -1) do
      delete :destroy, :id => researchers(:one).id
    end

    assert_redirected_to researchers_path
  end
end
