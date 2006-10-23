class IndexHappy < ActiveRecord::Migration
  def self.up
    remove_index :posts, :name => :index_posts_on_topic_id
    add_index :posts, [:forum_id, :created_at], :name => :index_posts_on_forum_id
    add_index :users, :last_seen_at, :name => :index_users_on_last_seen_at
    add_index :moderatorships, :forum_id, :name => :index_moderatorships_on_forum_id
  end

  def self.down
    remove_index :posts, :name => :index_posts_on_forum_id
    remove_index :users, :name => :index_users_on_last_seen_at
    remove_index :moderatorships, :name => :index_moderatorships_on_forum_id
    add_index :posts, [:topic_id, :created_at], :name => :index_posts_on_topic_id
  end
end
