class CreateTopics < ActiveRecord::Migration
  class Post < ActiveRecord::Base; end
  class Topic < ActiveRecord::Base; end
  def self.up
    create_table :topics do |t|
      t.column "forum_id",    :integer
      t.column "user_id",     :integer
      t.column "title",       :string
      t.column "created_at",  :datetime
      t.column "updated_at",  :datetime
      t.column "hits",        :integer,  :default => 0
      t.column "sticky",      :boolean,  :default => false
      t.column "posts_count", :integer,  :default => 0
      t.column "replied_at",  :datetime
    end
    # find the old topics
    Post.find(:all, :conditions => "id=topic_id").each do |old_topic|
      topic=Topic.new
      topic.id=old_topic.id
      topic.attribute_names.each do |prop|
        topic.send("#{prop}=", old_topic.send(prop))
        topic.save!
      end
    end
  end

  def self.down
    drop_table :topics
  end
end
