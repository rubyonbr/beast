require File.dirname(__FILE__) + '/../test_helper'
require 'user_mailer'

class UserMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"
  all_fixtures
  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @user = users(:joe)
  end

  def test_signup
    response = UserMailer.create_signup(@user, 'localhost') 
    assert_equal("Welcome to Beast", response.subject) 
    assert_equal(@user.email, response.to[0]) 
    assert_match(@user.login_key, response.body) 
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/user_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
