class TweakForumIndex < ActiveRecord::Migration
  def self.up
    remove_index :topics, :name => :index_topics_on_sticky_and_replied_at
    add_index :topics, [:forum_id, :sticky, :replied_at], :name => :index_topics_on_sticky_and_replied_at
  end

  def self.down
    remove_index :topics, :name => :index_topics_on_sticky_and_replied_at
    add_index :topics, [:sticky, :replied_at], :name => :index_topics_on_sticky_and_replied_at
  end
end
