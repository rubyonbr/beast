class SetUserDisplayName < ActiveRecord::Migration
  class User < ActiveRecord::Base ; end
  def self.up
    User.find(:all, :select => 'id, login, display_name').each do |u|
      u.update_attribute :display_name, u.login if u.display_name.blank?
    end
  end

  def self.down
  end
end
