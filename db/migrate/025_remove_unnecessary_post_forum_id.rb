class RemoveUnnecessaryPostForumId < ActiveRecord::Migration
  def self.up
    remove_column :posts, :forum_id
  end

  def self.down
    add_column :posts, :forum_id, :integer
  end
end
