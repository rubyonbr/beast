ActiveRecord::Schema.define(:version => 0) do
  create_table :topics, :force => true do |t|
    t.column :title, :string
  end

  create_table :posts, :force => true do |t|
    t.column :topic_id, :integer
    t.column :topic_type, :string
    t.column :type, :string
    t.column :body, :string
  end
end