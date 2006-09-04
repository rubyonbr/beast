class Sticky < ActiveRecord::Migration
  def self.up
    add_column "posts", "sticky", :boolean, :default => false
  end

  def self.down
    remove_column "posts", "sticky"
  end
end
