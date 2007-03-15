require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  all_fixtures

  # Replace this with your real tests.
  def test_display_name
    assert users(:aaron).display_name != users(:aaron).login
    assert_equal "sam", users(:sam).display_name
    # login overrules display_name when it is not present
    users(:aaron).update_attributes :display_name => ''
    assert_equal users(:aaron).login, users(:aaron).display_name
    users(:aaron).update_attributes :display_name => nil
    assert_equal users(:aaron).login, users(:aaron).display_name
  end
  
  def test_no_stupid_logins
    u = users(:sam)
    %w(bob max123 imthemanbetyoucanttouchme tj_supaman).each do |login|
      u.login = login
      assert_valid u
    end

    ['007', '1234556789', 'f451', "sam'er", "samm-ie", "<script>alert('im in ur base, killin ur d00ds')</script>"].each do |login|
      u.login = login
      assert ! u.valid?
    end
  end

  def test_email_address_validation
    u = users(:sam)
    u.email = "sam"
    assert ! u.valid?
    u.email = "johh.doe@google.com"
    assert u.valid?
    u.email = "johh_doe@mail.mx.1.google.com"
    assert u.valid?
    u.email = "johh_doe+crazy-iness@mail.mx.1.google.com"
    assert u.valid?
    u.email = "sam@@colgate.com"
    assert ! u.valid?
  end
  
  def test_minimum_password_length
    u = users(:sam)
    u.password = "bluegill"
    assert_valid u
    u.password = "fishing"
    assert_valid u
    u.password = "trout"
    assert_valid u
    # fewer than 5 chars are not valid passwords
    u.password = "bass"
    assert ! u.valid?
    u.password = "chi"
    assert ! u.valid?
  end
  
  def test_no_valid_display_names
    u=users(:sam)
    u.display_name="1234556789"
    assert ! u.valid?
    u.display_name="f451"
    assert ! u.valid?

    u.display_name="Josh Goebel"
    assert u.valid?
    u.display_name="Josh E. Goebel"
    assert u.valid?
    u.display_name="Zeph'er Cochran"
    assert u.valid?

  end
  
  def test_first_user_becomes_admin
    User.delete_all
    u=User.create(:email => "bob@aol.com", :password => "zoegirl", :password_confirmation => "zoegirl")
    u.login="bobby"
    assert u.save
    assert u.admin?
    assert u.activated?
    u=User.create(:email => "woody@aol.com", :password => "zoegirl", :password_confirmation => "zoegirl")
    u.login="woody"
    assert ! u.admin?    
    assert ! u.activated?
  end
  
  def test_login_token
    assert_nil users(:aaron).login_key
    assert_nil users(:aaron).login_key_expires_at
    users(:aaron).reset_login_key!
    assert_equal 40, users(:aaron).login_key.length
    assert users(:aaron).login_key_expires_at < Time.now.utc+1.year+1.minute
    assert users(:aaron).login_key_expires_at > Time.now.utc+1.year-1.minute
  end
  
  def test_open_id_login
    u = User.new(:identity_url => 'http://foo', :email => 'zoe@girl.com')
    u.login = 'zoegirl'
    assert_valid u
  end
end
