class TopicsCacheLastRepliedUser < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  class Topic < ActiveRecord::Base
    has_many :posts
  end
  def self.up
    add_column "topics", "replied_by", :integer
    add_column "topics", "last_post_id", :integer
    Topic.find(:all).each do |topic|
      next if topic.posts.count.zero?
      topic.replied_by   = topic.last_post.user_id
      topic.last_post_id = topic.last_post.id
      topic.save!
    end
  end

  def self.down
    remove_column "topics", "replied_by"
    remove_column "topics", "last_post_id"
  end
end
