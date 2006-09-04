class RemoveUnusedUserProfile < ActiveRecord::Migration
  def self.up
    remove_column "users", "aim"
    remove_column "users", "yahoo"
    remove_column "users", "google_talk"
    remove_column "users", "msn"
    add_column "users", "bio", :string
  end

  def self.down
    add_column "users", "aim",                  :string
    add_column "users", "yahoo",                :string
    add_column "users", "google_talk",          :string
    add_column "users", "msn",                  :string
    remove_column "users", "bio"
  end
end
