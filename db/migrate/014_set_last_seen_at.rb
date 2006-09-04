class SetLastSeenAt < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      if user.last_seen_at.nil?
        user.last_seen_at=Time.now.utc
        user.save!
      end
    end
  end

  def self.down
  end
end
