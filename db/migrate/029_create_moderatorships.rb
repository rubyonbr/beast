class CreateModeratorships < ActiveRecord::Migration
  def self.up
    create_table :moderatorships do |t|
      t.column :forum_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :moderatorships
  end
end
