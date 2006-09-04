class PositionForForums < ActiveRecord::Migration
  def self.up
    add_column "forums", "position", :integer
  end

  def self.down
    remove_column "forums", "position"
  end
end
