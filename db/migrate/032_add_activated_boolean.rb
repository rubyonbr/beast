class AddActivatedBoolean < ActiveRecord::Migration
  class User < ActiveRecord::Base ; end
  def self.up
    add_column "users", "activated", :boolean, :default => false
    say_with_time("Activating all current users...") { User.update_all ['activated = ?', true] }
  end

  def self.down
    remove_column "users", "activated"
  end
end
