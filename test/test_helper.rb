ENV["RAILS_ENV"]     = "test"
PASSWORD_SALT = 'beast'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  def self.all_fixtures
    fixtures :forums, :users, :posts, :topics, :moderatorships, :monitorships
  end

  def assert_difference(object, method = nil, difference = 1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method), "#{object}##{method}"
  end
  
  def login_as(user)
    @request.session[:user_id] = user ? users(user).id : nil
    @request.session[:topics] = {}
  end

  def authorize_as(user, mime_type = 'application/xml')
    @request.env["HTTP_AUTHORIZATION"] = user ? "Basic #{Base64.encode64("#{users(user).login}:testy")}" : nil
  end

  def logout
    @request.session[:user_id] = nil
    @controller.instance_variable_set("@current_user",nil)
  end

  def content_type(type)
    @request.env['Content-Type'] = type
  end

  def accept(accept)
    @request.env["HTTP_ACCEPT"] = accept
  end

  def assert_models_equal(expected_models, actual_models, message = nil)
    to_test_param = lambda { |r| "<#{r.class}:#{r.to_param}>" }
    full_message = build_message(message, "<?> expected but was\n<?>.\n", 
      expected_models.collect(&to_test_param), actual_models.collect(&to_test_param))
    assert_block(full_message) { expected_models == actual_models }
  end
end
