class AddPostsUsersIndex < ActiveRecord::Migration
  def self.up
    remove_index "posts", :name => "index_posts_on_user_id"
    add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id"
  end

  def self.down
    remove_index "posts", :name => "index_posts_on_user_id"
    add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  end
end
