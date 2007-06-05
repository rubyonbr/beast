class Topic < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_many :monitorships
  has_many :monitors, :through => :monitorships, :conditions => ["#{Monitorship.table_name}.active = ?", true], :source => :user, :order => "#{User.table_name}.login"

  has_many :posts, :order => "#{Post.table_name}.created_at", :dependent => :destroy do
    def last
      @last_post ||= find(:first, :order => "#{Post.table_name}.created_at desc")
    end
  end
  
  has_many :voices, :through => :posts, :source => :user, :uniq => true

  belongs_to :replied_by_user, :foreign_key => "replied_by", :class_name => "User"
  
  validates_presence_of :forum, :user, :title
  before_create :set_default_replied_at_and_sticky
  before_update :check_for_changing_forums
  after_save    :update_forum_counter_cache
  after_destroy :update_forum_counter_cache

  attr_accessible :title
  # to help with the create form
  attr_accessor :body
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def sticky?() sticky == 1 end

  def views() hits end

  def paged?() posts_count > 25 end
  
  def last_page
    (posts_count.to_f / 25.0).ceil.to_i
  end

  def editable_by?(user)
    user && (user.id == user_id || user.admin? || user.moderator_of?(forum_id))
  end
  
  def update_cached_post_fields(post)
    # these fields are not accessible to mass assignment
    last_post = post.frozen? ? posts.last : post
    if last_post
      self.class.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?, posts_count = ?', last_post.created_at, last_post.user_id, last_post.id, posts.count], ['id = ?', id])
    else
      self.class.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?, posts_count = ?', nil, nil, nil, 0], ['id = ?', id])
    end
  end
  
  protected
    def set_default_replied_at_and_sticky
      self.replied_at = Time.now.utc
      self.sticky   ||= 0
    end

    def set_post_forum_id
      Post.update_all ['forum_id = ?', forum_id], ['topic_id = ?', id]
    end

    def check_for_changing_forums
      old = Topic.find(id)
      @old_forum_id = old.forum_id if old.forum_id != forum_id
      true
    end
    
    def update_forum_counter_cache
      forum_conditions = ['topics_count = ?', Topic.count(:all, :conditions => {:forum_id => forum_id})]
      if !frozen? && @old_forum_id && @old_forum_id != forum_id
        set_post_forum_id
        Forum.update_all ['topics_count = ?, posts_count = ?', 
          Topic.count(:all, :conditions => {:forum_id => @old_forum_id}),
          Post.count(:all,  :conditions => {:forum_id => @old_forum_id})], ['id = ?', @old_forum_id]
        forum_conditions.first << ", posts_count = ?"
        forum_conditions       << Post.count(:all, :conditions => {:forum_id => forum_id})
      end
      Forum.update_all forum_conditions, ['id = ?', forum_id]
      @old_forum_id = nil
    end
end
