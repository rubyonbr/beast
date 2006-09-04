class AddTopicLastPostedAtDate < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  def self.up
    add_column "posts", "replied_at", :datetime
    Post.update_all 'replied_at = updated_at', 'topic_id = id'
  end

  def self.down
    remove_column "posts", "replied_at"
  end
end
