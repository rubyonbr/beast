class ChangeStickyToInteger < ActiveRecord::Migration
  class Topic < ActiveRecord::Base; end
  def self.up
    sticky_topics = Topic.find_all_by_sticky(true).collect &:id
    change_column :topics, :sticky, :integer, :default => 0
    Topic.update_all 'sticky=1', ['id in (?)', sticky_topics]
  end

  def self.down
    change_column :topics, :sticky, :boolean, :default => false
  end
end
