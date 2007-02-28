class RecentTopicsIndex < ActiveRecord::Migration
  def self.up
    # this index needed for when we get recent posts only and bypass the sticky bit
    # in that case the databaes would be unable to use the existing index
    add_index :topics, [:forum_id, :replied_at]
  end

  def self.down
    remove_index :topics, [:forum_id, :replied_at]
  end
end
