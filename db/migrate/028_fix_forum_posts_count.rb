class FixForumPostsCount < ActiveRecord::Migration
  class Post  < ActiveRecord::Base; end
  class Forum < ActiveRecord::Base; end
  def self.up
    Post.count(:all, :group => :forum_id).each do |forum_id, count|
      Forum.update_all ['posts_count = ?', count], ['id = ?', forum_id]
    end
  end

  def self.down
  end
end
