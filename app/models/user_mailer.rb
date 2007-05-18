class UserMailer < ActionMailer::Base

  def signup(user, domain, sent_at = Time.now)
    @subject    = 'Welcome to Beast'[:beast_welcome]
    @body       = {:user => user, :domain => domain}
    @recipients = user.email
    @from       = 'beast@' + domain.split(":").first
    @sent_on    = sent_at
    @headers    = {}
  end
  
end