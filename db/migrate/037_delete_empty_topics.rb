class DeleteEmptyTopics < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  class Topic < ActiveRecord::Base
    has_many :posts
  end
  def self.up
    Topic.find(:all).each do |topic| 
      topic.destroy if topic.posts.count.zero?
    end
  end

  def self.down
  end
end
