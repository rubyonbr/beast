class TopicLocked < ActiveRecord::Migration
  def self.up
    add_column "topics", "locked", :boolean, :default => false
    Topic.update_all [ "locked= ? ", false ]
  end

  def self.down
    remove_column "topics", "locked"
  end
end