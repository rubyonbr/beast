require 'digest/sha1'

class User < ActiveRecord::Base
  has_many :moderatorships, :dependent => :destroy
  has_many :forums, :through => :moderatorships, :order => 'forums.name'

  has_many :posts
  has_many :topics
  has_many :monitorships
  has_many :monitored_topics, :through => :monitorships, :conditions => ['monitorships.active = ?', true], :order => 'topics.replied_at desc', :source => :topic

  validates_presence_of     :login, :email, :password_hash
  validates_length_of       :login, :minimum => 2
  validates_length_of :password, :minimum => 5, :allow_nil => true
  validates_confirmation_of :password, :on => :create

  # names that start with #s really upset me for some reason
  validates_format_of       :login, :with => /^[a-z]{2}(?:\w+)?$/i

  # names that start with #s really upset me for some reason
  validates_format_of     :display_name, :with => /^[a-z]{2}(?:[.'\-\w ]+)?$/i

  validates_uniqueness_of   :login, :email, :display_name, :case_sensitive => false
  before_validation { |u| u.display_name = u.login if u.display_name.blank? }
  # first user becomes admin automatically
  before_create { |u| u.admin = u.activated = true if User.count == 0 }
  format_attribute :bio

  attr_reader :password
  attr_protected :admin, :posts_count, :login, :created_at, :updated_at, :last_login_at, :topics_count, :activated

  def self.currently_online
    User.find(:all, :conditions => ["last_seen_at > ?", Time.now.utc-5.minutes])
  end

  # we allow false to be passed in so a failed login can check
  # for an inactive account to show a different error
  def self.authenticate(login, password, activated=true)
    find_by_login_and_password_hash_and_activated(login, Digest::SHA1.hexdigest(password + PASSWORD_SALT), activated)
  end

  def password=(value)
    return if value.blank?
    write_attribute :password_hash, Digest::SHA1.hexdigest(value + PASSWORD_SALT)
    @password = value
  end
  
  def reset_login_key!
    self.login_key = Digest::SHA1.hexdigest(Time.now.to_s + password_hash.to_s + rand(123456789).to_s).to_s
    # this is not currently honored
    self.login_key_expires_at = Time.now.utc+1.year
    save!
    login_key
  end

  def moderator_of?(forum)
    moderatorships.count(:all, :conditions => ['forum_id = ?', (forum.is_a?(Forum) ? forum.id : forum)]) == 1
  end

end
