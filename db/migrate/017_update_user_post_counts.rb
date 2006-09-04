class UpdateUserPostCounts < ActiveRecord::Migration
  def self.up
    # old and not needed, we only need to know post count
    remove_column "users", "topics_count"
    # because i think the counts have been off
    User.find(:all).each do | i |
      i.posts_count=i.posts.count
      i.save
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
