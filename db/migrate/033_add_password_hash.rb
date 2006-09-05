require 'digest/sha1'
class AddPasswordHash < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  def self.up
    # you need to edit your environment.rb and pick a non-default password salt
    # before you continue
    raise "ChangePasswordHash" if PASSWORD_SALT == '48e45be7d489cbb0ab582d26e2168621'
    say_with_time "Hashing all your passwords in 30 seconds... this is a big deal (because it's not reversible), cancel if you aren't ready." do
      sleep 30
    end
    rename_column :users, :password, :password_hash
    say_with_time "Hashing passwords..." do
      User.find(:all, :select => 'id, password_hash').each do |u|
        u.update_attribute :password_hash, Digest::SHA1.hexdigest(u.password_hash.to_s + PASSWORD_SALT)
      end
    end
  end

  def self.down
    raise IrreversibleMigration
#    rename_column :users, :password_hash, :password # the users will have some... interesting passwords now
  end
end
