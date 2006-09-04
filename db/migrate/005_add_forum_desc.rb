class AddForumDesc < ActiveRecord::Migration
  def self.up
    add_column "forums", "description", :string
  end

  def self.down
    remove_column "forums", "description"
  end
end
