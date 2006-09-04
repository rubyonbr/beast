module AuthenticationSystem
  protected
    # this is used to keep track of the last time a user has been seen (reading a topic)
    # it is used to know when topics are new or old and which should have the green
    # activity light next to them
    #
    # we cheat by not calling it all the time, but rather only when a user views a topic
    # which means it isn't truly "last seen at" but it does serve it's intended purpose
    #
    # this could be a filter for the entire app and keep with it's true meaning, but that 
    # would just slow things down without any forseeable benefit since we already know 
    # who is online from the user/session connection 
    def update_last_seen_at
      User.update_all ['last_seen_at = ?', Time.now.utc], ['id = ?', current_user.id] if logged_in?
    end
    
    def login_required
      login_by_token unless logged_in?
      redirect_to login_path unless logged_in? && authorized?
    end
    
    def login_by_token
      self.current_user = User.find_by_id_and_login_key(*cookies[:login_token].split(";")) if cookies[:login_token] and not logged_in?
    end
    
    def authorized?() true end

    def current_user=(value)
      if @current_user = value
        session[:user_id] = @current_user.id 
        # need to remove the unless RAILS_ENV when figure out how
        # to make this work with tests
        session.model.user_id = @current_user.id unless RAILS_ENV == "test"
        # this is used while we're logged in to know which threads are new, etc
        session[:last_active] = @current_user.last_seen_at
        session[:topics] = session[:forums] = {}
        update_last_seen_at
      end
    end

    def current_user
      @current_user ||= ((session[:user_id] && User.find_by_id(session[:user_id])) || 0)
    end
    
    def logged_in?() current_user != 0 end
    
    def admin?() logged_in? and current_user.admin? end
end