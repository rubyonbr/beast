class ReAddPostsForumId < ActiveRecord::Migration
  class Topic < ActiveRecord::Base; end
  class Post  < ActiveRecord::Base; end
  def self.up
    add_column "posts", "forum_id", :integer
    Topic.find(:all, :select => 'id, forum_id').each do |t|
      Post.update_all ['forum_id = ?', t.forum_id], ['topic_id = ?', t.id]
    end
  end

  def self.down
    remove_column "posts", "forum_id"
  end
end
