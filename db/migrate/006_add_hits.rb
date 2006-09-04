class AddHits < ActiveRecord::Migration
  def self.up
    add_column "posts", "hits", :integer, :default => 0 
  end

  def self.down
    remove_column "posts", "hits"
  end
end
