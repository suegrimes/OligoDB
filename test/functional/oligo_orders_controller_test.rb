require 'test_helper'

class OligoOrdersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:oligo_orders)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_oligo_order
    assert_difference('OligoOrder.count') do
      post :create, :oligo_order => { }
    end

    assert_redirected_to oligo_order_path(assigns(:oligo_order))
  end

  def test_should_show_oligo_order
    get :show, :id => oligo_orders(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => oligo_orders(:one).id
    assert_response :success
  end

  def test_should_update_oligo_order
    put :update, :id => oligo_orders(:one).id, :oligo_order => { }
    assert_redirected_to oligo_order_path(assigns(:oligo_order))
  end

  def test_should_destroy_oligo_order
    assert_difference('OligoOrder.count', -1) do
      delete :destroy, :id => oligo_orders(:one).id
    end

    assert_redirected_to oligo_orders_path
  end
end
