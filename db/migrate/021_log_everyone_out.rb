class LogEveryoneOut < ActiveRecord::Migration
  def self.up
    Session.delete_all
  end

  def self.down
    raise IrreversibleMigration
  end
end
