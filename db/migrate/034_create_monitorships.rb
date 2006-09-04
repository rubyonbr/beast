class CreateMonitorships < ActiveRecord::Migration
  def self.up
    create_table :monitorships do |t|
      t.column :topic_id, :integer
      t.column :user_id, :integer
      t.column :active, :boolean, :default => true
    end
  end

  def self.down
    drop_table :monitorships
  end
end
