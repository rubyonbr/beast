class RenameIdentityUrlToOpenidUrl < ActiveRecord::Migration
  def self.up
    rename_column :users, :identity_url, :openid_url
  end

  def self.down
    rename_column :users, :openid_url, :identity_url
  end
end
