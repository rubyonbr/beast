require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:users)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_user
    assert_difference User, :count do 
      post :create, :user => { :login => 'nico', :email => 'nico@email.com', :password => 'fooey', :password_confirmation => 'fooey' }
    end
    assert_not_nil assigns(:user).login_key
    assert !assigns(:user).activated?
    assert_redirected_to login_path
# => JOSH: can be removed if new sessions stuff works out
#    assert_not_nil assigns(:user).last_seen_at

#    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_reset_login_key_for_forgotten_password
    old_key = users(:sam).login_key
    assert_difference User, :count, 0 do
      post :create, :email => users(:sam).email
    end
    assert_redirected_to login_path
    assert old_key != users(:sam).reload.login_key
  end
  
  def test_should_not_bomb_when_resetting_invalid_email
    assert_difference User, :count, 0 do
      post :create, :email => 'whatever'
    end
    assert_redirected_to login_path
  end

  def test_should_show_user
    get :show, :id => 1
    assert_response :success
  end

  def test_should_require_valid_user
    login_as :sam
    get :edit, :id => users(:aaron).id
    assert_redirected_to login_path
  end

  def test_should_get_edit
    login_as :aaron
    get :edit, :id => users(:aaron).id
    assert_response :success
  end

  def test_should_get_edit_as_admin
    login_as :aaron
    get :edit, :id => users(:sam).id
    assert_response :success
  end
  
  def test_should_update_user
    login_as :aaron
    put :update, :id => 1, :user => { }
    assert_redirected_to edit_user_path(assigns(:user))
  end

  def test_should_only_update_safe_fields
    # non-admin should not be able to change all this stuff
    login_as :sam
    put :update, :id => users(:sam).id, :user => { :login => "ruby", :created_at => "2005-10-24", :updated_at => "2004-10-24", :last_login_at => "2005-10-24", :last_seen_at => "2005-10-24", :posts_count => "1000", :admin => "1" }
    assert_redirected_to edit_user_path(assigns(:user))
    assert_equal users(:sam), assigns(:user)
    [:created_at, :last_login_at, :posts_count, :admin].each do |attr|
      assert_equal users(:sam).send(attr), assigns(:user).send(attr), "#{attr}"
    end
    assert_not_equal 2004, users(:sam).reload.updated_at.year
    assert_not_equal 2005, users(:sam).last_seen_at
    assert_equal 'sam', users(:sam).login
    assert_equal 2, users(:sam).posts_count
    assert !users(:sam).admin?
  end

  def test_admin_can_destroy_user
    login_as :aaron
    old_count = User.count
    delete :destroy, :id => 2
    assert_equal old_count-1, User.count
    
    assert_redirected_to users_path
  end

  def test_normal_user_cannot_destroy_others
    login_as :sam
    old_count = User.count
    delete :destroy, :id => 1
    assert_equal old_count, User.count
    
    assert_redirected_to login_path
  end

  def test_should_set_admin
    assert !users(:sam).admin?
    
    login_as :aaron
    post :admin, :id => users(:sam).id, :user => { :admin => '1' }
    assert_redirected_to user_path(users(:sam))
    
    assert users(:sam).reload.admin?
  end

  def test_should_add_moderator
    assert !users(:sam).moderator_of?(forums(:comics))
    
    login_as :aaron
    post :admin, :id => users(:sam).id, :user => { :admin => '1' }, :moderator => forums(:comics)
    assert_redirected_to user_path(users(:sam))
    
    assert users(:sam).moderator_of?(forums(:comics))
  end

  def test_should_require_admin_to_set_admin_properties
    login_as :sam
    post :admin, :id => users(:sam).id
    assert_redirected_to login_path
  end

  # users should not be able to destroy themselves unless we're using AAP or something
  def test_normal_user_cannot_destroy_themselves
    login_as :sam
    assert_difference User, :count, 0 do
      delete :destroy, :id => users(:sam).id
    end
    assert_redirected_to login_path
  end

  def test_should_activate_user
    assert !users(:kyle).activated?
    get :activate, :key => users(:kyle).login_key
    assert_redirected_to home_path
    assert users(:kyle).reload.activated?
    assert_equal users(:kyle).id, session[:user_id]
  end
  
  def test_should_not_activate_invalid_key
    get :activate, :key => 'bad key'
    assert_redirected_to home_path
  end
  
  def test_should_not_disturb_activated_user
    assert users(:sam).activated?
    get :activate, :key => users(:sam).login_key
    assert users(:sam).reload.activated?
    assert_redirected_to home_path
  end
end
