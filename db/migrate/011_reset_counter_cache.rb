class ResetCounterCache < ActiveRecord::Migration
  def self.up
    
    Forum.find(:all).each do | forum |
      forum.topics_count=forum.topics.count
      forum.posts_count=forum.posts.count
      forum.save
    end
    
    Post.find(:all).each do | i |
      i.posts_count=i.posts.count
      i.save
    end

    User.find(:all).each do | i |
      i.posts_count=i.posts.count
      i.save
    end
  end

  def self.down
  end
end
