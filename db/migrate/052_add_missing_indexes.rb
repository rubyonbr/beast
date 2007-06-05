class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index "posts", ["topic_id", "created_at"], :name => "index_posts_on_topic_id"
    add_index "users", ["posts_count"], :name => "index_users_on_posts_count"
  end

  def self.down
    remove_index "posts", :name => "index_posts_on_topic_id"
    remove_index "users", :name => "index_users_on_posts_count"
  end
end
