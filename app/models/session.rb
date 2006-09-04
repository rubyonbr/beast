Session = CGI::Session::ActiveRecordStore::Session
Session.class_eval do
  
  def self.active_guests
    count(:all, :conditions => ["user_id is NULL and updated_at > ?", 5.minutes.ago.utc])
  end

  def self.sweep!
    delete_all ['updated_at < ?', 15.minutes.ago.utc]
  end
end