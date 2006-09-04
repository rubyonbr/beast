class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.column :forum_id, :integer
      t.column :user_id, :integer
      t.column :post_id, :integer
      t.column :title, :string
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :posts
  end
end
