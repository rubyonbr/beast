class TopicIndex < ActiveRecord::Migration
  def self.up
    add_index :topics, [:sticky, :replied_at], :name => :index_topics_on_sticky_and_replied_at
  end

  def self.down
    remove_index :topics, :name => :index_topics_on_sticky_and_replied_at
  end
end
