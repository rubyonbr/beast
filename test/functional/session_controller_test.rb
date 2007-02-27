require File.dirname(__FILE__) + '/../test_helper'
require 'session_controller'

# Re-raise errors caught by the controller.
class SessionController; def rescue_action(e) raise e end; end

class SessionControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = SessionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login
    old = users(:aaron).last_seen_at
    post :create, :login => 'aaron', :password => 'testy'
    assert_redirected_to home_path
    assert_equal users(:aaron).id, session[:user_id]
    assert old != users(:aaron).reload.last_seen_at
    assert_equal old, @controller.send(:last_active)
  end

  def test_remember_me
    post :create, :login => 'aaron', :password => 'testy', :remember_me => "1"
    users(:aaron).reload
    
    assert cookies['login_token']
    assert_equal("1;#{users(:aaron).login_key}", cookies['login_token'].first)
    assert_not_nil users(:aaron).login_key
    assert_not_nil users(:aaron).login_key_expires_at

    #log off
    post :destroy
    assert cookies['login_token'].empty?

    # make sure it change if log in again
    sleep 1
    old = users(:aaron).clone
    post :create, :login => 'aaron', :password => 'testy', :remember_me => "1"
    users(:aaron).reload
    assert_not_equal(old.login_key, users(:aaron).login_key)
    assert_not_equal(old.login_key_expires_at, users(:aaron).login_key_expires_at)
  end

  def test_should_fail_login_for_unactivated_user
    post :create, :login => 'kyle', :password => 'testy'
    assert_response :success
    assert_template 'new'
    assert_nil session[:user_id]
  end

  def test_should_fail_login
    post :create, :login => 'aaron', :password => 'bad'
    assert_response :success
    assert_template 'new'
    assert_nil session[:user_id]
  end
  
  def test_should_logout
    login_as :aaron
    get :destroy
    assert_redirected_to home_path
    assert_nil session[:user_id]
  end

  def test_should_find_no_user_from_empty_session
    get :new
    assert_equal 0, @controller.send(:current_user)
  end

  def test_should_find_current_user_from_session
    login_as :aaron
    get :new
    assert_equal users(:aaron), @controller.send(:current_user)
  end
  
  def test_should_show_negative_logged_in_status
    get :new
    assert !@controller.send(:logged_in?)
  end
  
  def test_should_show_positive_logged_in_status
    login_as :aaron
    get :new
    assert @controller.send(:logged_in?)
  end
  
  def test_should_show_negative_admin_status_when_logged_out
    get :new
    assert !@controller.send(:admin?)
  end
  
  def test_should_show_negative_admin_status
    login_as :sam
    get :new
    assert !@controller.send(:admin?)
  end
  
  def test_should_show_positive_admin_status
    login_as :aaron
    get :new
    assert @controller.send(:admin?)
  end
end
