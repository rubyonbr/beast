class LoginByKeyFields < ActiveRecord::Migration
  def self.up
    add_column "users", "login_key", :string
    add_column "users", "login_key_expires_at", :datetime
  end

  def self.down
    remove_column "users", "login_key"
    remove_column "users", "login_key_expires_at"
  end
end
