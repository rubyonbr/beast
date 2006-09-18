class FixLastPosts < ActiveRecord::Migration
  class Topic < ActiveRecord::Base
    has_many :posts, :order => 'posts.created_at'
  end
  class Post  < ActiveRecord::Base; end

  def self.up
    Topic.find(:all, :include => :posts).each do |topic|
      say_with_time "fixing #{topic.title}" do
        post = topic.posts.last
        Topic.update_all(['replied_at = ?, replied_by = ?, last_post_id = ?', 
          post.created_at, post.user_id, post.id], ['id = ?', topic.id]) if post
      end
    end
  end

  def self.down
  end
end
