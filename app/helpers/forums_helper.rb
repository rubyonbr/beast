module ForumsHelper
  
  # used to know if a topic has changed since we read it last
  def recent_topic_activity(topic)
    return false if not logged_in?
    return topic.replied_at > (session[:topics][topic.id] || last_login)
  end 
  
  # used to know if a forum has changed since we read it last
  def recent_forum_activity(forum)
    return false if forum.topics.empty? or not logged_in?
    return forum.topics.first.replied_at > (session[:forums][forum.id] || last_login)
  end
  
end
