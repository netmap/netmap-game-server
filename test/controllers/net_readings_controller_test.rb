require 'test_helper'

class NetReadingsControllerTest < ActionController::TestCase
  setup do
    @net_reading = net_readings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:net_readings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create net_reading" do
    assert_difference('NetReading.count') do
      post :create, net_reading: { digest: @net_reading.digest, json_data: @net_reading.json_data, player_id_id: @net_reading.player_id_id }
    end

    assert_redirected_to net_reading_path(assigns(:net_reading))
  end

  test "should show net_reading" do
    get :show, id: @net_reading
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @net_reading
    assert_response :success
  end

  test "should update net_reading" do
    patch :update, id: @net_reading, net_reading: { digest: @net_reading.digest, json_data: @net_reading.json_data, player_id_id: @net_reading.player_id_id }
    assert_redirected_to net_reading_path(assigns(:net_reading))
  end

  test "should destroy net_reading" do
    assert_difference('NetReading.count', -1) do
      delete :destroy, id: @net_reading
    end

    assert_redirected_to net_readings_path
  end
end
