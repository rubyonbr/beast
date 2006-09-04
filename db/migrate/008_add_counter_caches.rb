class AddCounterCaches < ActiveRecord::Migration
  def self.up
    add_column "users", "topics_count",  :integer, :default => 0
    add_column "forums", "topics_count", :integer, :default => 0
    add_column "forums", "posts_count",  :integer, :default => 0
    add_column "posts", "posts_count",   :integer, :default => 0
  end

  def self.down
    remove_column "users", "topics_count"
    remove_column "forums", "topics_count"
    remove_column "forums", "posts_count"
    remove_column "posts", "posts_count"
  end
end
