class DowncaseAllEmails < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  def self.up
    User.paginated_each :select => 'id, email' do |user|
      User.update_all ['email = ?', user.email.downcase], ['id = ?', user.id] unless user.email.blank?
    end
  end

  def self.down
  end
end
