require File.dirname(__FILE__) + '/../test_helper'
require 'forums_controller'

# Re-raise errors caught by the controller.
class ForumsController; def rescue_action(e) raise e end; end

class ForumsControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = ForumsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # test remembering pages
  
  def test_forum_index_resets_page_variable
    @request.session[:forum_page]=Hash.new(1)
    get :index, :id => 1
    assert_equal nil, session[:forum_page]
  end
  
  def test_forum_view_sets_page_variable
    get :show, :id =>1, :page =>3 
    assert_equal 3, session[:forum_page][1]
  end



  def test_remember_me_logs_into_home
    @request.cookies['login_token'] = CGI::Cookie.new('login_token', [users(:sam).id.to_s, users(:sam).login_key].join(';'))
    get :index
    assert_equal users(:sam).id, session[:user_id]
  end

  def test_remember_me_logs_in_when_login_required
    users(:aaron).login_key = "8305f94ab2b92f99137abbc235ee28e5"
    users(:aaron).login_key_expires_at = Time.now.utc+1.week
    users(:aaron).save!
    @request.cookies['login_token'] = CGI::Cookie.new('login_token', [users(:aaron).id.to_s, users(:aaron).login_key].join(';'))
    get :edit, :id => users(:aaron).id
    assert_equal users(:aaron).id, session[:user_id]
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:forums)
    assert_select 'html>head'
  end

  def test_should_get_index_with_xml
    content_type 'application/xml'
    get :index, :format => 'xml'
    assert_response :success
    assert_select 'forums>forum'
  end

  def test_should_get_new
    login_as :aaron
    get :new
    assert_response :success
  end
  
  def test_should_require_admin
    login_as :sam
    get :new
    assert_redirected_to login_path
  end
  
  def test_should_create_forum
    login_as :aaron
    assert_difference Forum, :count do
      post :create, :forum => { :name => 'yeah' }
    end
    
    assert_redirected_to forums_path
  end
  
  def test_should_create_forum_with_xml
    content_type 'application/xml'
    authorize_as :aaron

    assert_difference Forum, :count do
      post :create, :forum => { :name => 'yeah' }, :format => 'xml'
    end
    
    assert_response :created
    assert_equal formatted_forum_url(:id => assigns(:forum), :format => :xml), @response.headers["Location"]
  end

  def test_should_show_forum
    get :show, :id => 1
    assert_response :success
    assert assigns(:topics)
    # sticky should be first
    assert_equal(topics(:sticky), assigns(:topics).first)
    assert_select 'html>head'
  end
  
  def test_should_show_forum_with_xml
    content_type 'application/xml'
    get :show, :id => 1, :format => 'xml'
    assert_response :success
    assert_select 'forum'
  end

  def test_should_get_edit
    login_as :aaron
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_forum
    login_as :aaron
    put :update, :id => 1, :forum => { }
    assert_redirected_to forums_path
  end

  def test_should_update_forum_with_xml
    authorize_as :aaron
    content_type 'application/xml'
    put :update, :id => 1, :forum => { }, :format => 'xml'
    assert_response :success
  end

  def test_should_destroy_forum
    login_as :aaron
    old_count = Forum.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Forum.count
    
    assert_redirected_to forums_path
  end

  def test_should_destroy_forum_with_xml
    authorize_as :aaron
    content_type 'application/xml'
    old_count = Forum.count
    delete :destroy, :id => 1, :format => 'xml'
    assert_equal old_count-1, Forum.count
    assert_response :success
  end
end
