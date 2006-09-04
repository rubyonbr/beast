class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :forums
  end
end
