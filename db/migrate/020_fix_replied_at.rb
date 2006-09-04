class FixRepliedAt < ActiveRecord::Migration
  def self.up
    execute 'update posts set replied_at=created_at where replied_at is null and id=topic_id'
  end

  def self.down
  end
end
