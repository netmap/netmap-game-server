require 'test_helper'

class DevModeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
