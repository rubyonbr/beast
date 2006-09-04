class UserMailer < ActionMailer::Base

  def signup(user, domain, sent_at = Time.now)
    @subject    = 'Welcome to Beast'
    @body       = {:user => user, :domain => domain}
    @recipients = user.email
    @from       = 'beast@'+domain
    @sent_on    = sent_at
    @headers    = {}
  end
  
end