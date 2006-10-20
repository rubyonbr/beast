class AddPostsBodyHtml < ActiveRecord::Migration
  def self.up
    add_column "posts",  "body_html",        :text
    add_column "users",  "bio_html",         :text
    add_column "forums", "description_html", :text
    [Post, Forum, User].each do |klass|
      klass.transaction do
        klass.find(:all).each do |record|
          begin
            record.save_without_validation!
          rescue
            puts message_for_record(record, "[#{$!.class.name}] #{$!.message}")
          end
        end
      end
    end
  end

  def self.down
    remove_column "posts", "body_html"
    remove_column "users", "bio_html"
    remove_column "forums", "description_html"
  end
  
  private
    def self.message_for_record(record, message)
      case record
        when Post
          "Post ##{record.id} of /forums/#{record.forum_id}/topics/#{record.topic_id}"
        when User
          "User #{record.display_name} /users/##{record.id}"
        when Forum
          "Forum /forums/##{record.id}"
      end << " errored with: '#{message}'"
    end
end
