require File.dirname(__FILE__) + '/../test_helper'
require 'monitorships_controller'

# Re-raise errors caught by the controller.
class MonitorshipsController; def rescue_action(e) raise e end; end

class MonitorshipsControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = MonitorshipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_require_login
    post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
    assert_redirected_to login_path
  end
  
  def test_should_add_monitorship
    login_as :joe
    assert_difference Monitorship, :count do 
      post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:joe).id
    end
    
    assert topics(:pdi).monitors(true).include?(users(:joe))
  end
  
  def test_should_activate_monitorship
    login_as :sam
    assert_difference Monitorship, :count, 0 do
      post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:sam).id
    end
  end
  
  def test_should_not_duplicate_monitorship
    login_as :aaron
    assert_difference Monitorship, :count, 0 do
      post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
    end
  end
  
  def test_should_deactivate_monitorship
    login_as :aaron
    assert_difference Monitorship, :count, 0 do
      delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
    end

    assert !topics(:pdi).monitors(true).include?(users(:aaron))
  end
end
