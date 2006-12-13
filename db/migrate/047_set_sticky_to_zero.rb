class SetStickyToZero < ActiveRecord::Migration
  class Topic < ActiveRecord::Base; end
  def self.up
    Topic.update_all ['sticky = 0'], ['sticky is null']
  end

  def self.down
  end
end
