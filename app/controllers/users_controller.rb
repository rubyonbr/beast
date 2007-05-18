class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy, :admin]
  before_filter :find_user,      :only => [:edit, :update, :destroy, :admin]

  def index
    respond_to do |format|
      format.html do
        @user_pages, @users = paginate(:users, :per_page => 50, :order => "display_name", :conditions => User.build_search_conditions(params[:q]))
        @user_count = User.count
        @active     = User.count(:all, :conditions => "posts_count > 0")
      end
      format.xml do
        @users = User.search(params[:q], :limit => 25)
        render :xml => @users.to_xml
      end
    end
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.xml { render :xml => @user.to_xml }
    end
  end

  def new
    @user = User.new
  end
  
  def create
    respond_to do |format|
      format.html do
        @user = params[:user].blank? ? User.find_by_email(params[:email]) : User.new(params[:user])
        flash[:error] = "I could not find an account with the email address '{email}'. Did you type it correctly?"[:could_not_find_account_message, CGI.escapeHTML(params[:email])] if params[:email] and not @user
        redirect_to login_path and return unless @user
        @user.login = params[:user][:login] unless params[:user].blank?
        @user.reset_login_key! 
        begin
          UserMailer.deliver_signup(@user, request.host_with_port)
        rescue Net::SMTPFatalError => e
          flash[:notice] = "A permanent error occured while sending the signup message to '{email}'. Please check the e-mail address."[:signup_permanent_error_message, CGI.escapeHTML(@user.email)]
          redirect_to :action => "new"
        rescue Net::SMTPServerBusy, Net::SMTPUnknownError, \
          Net::SMTPSyntaxError, TimeoutError => e
          flash[:notice] = "The signup message cannot be sent to '{email}' at this moment. Please, try again later."[:signup_cannot_sent_message, CGI.escapeHTML(@user.email)]
          redirect_to :action => "new"
        end
        flash[:notice] = params[:email] ? "A temporary login email has been sent to '{email}'."[:temporary_login_message, CGI.escapeHTML(@user.email)] : "An account activation email has been sent to '{email}'."[:account_activation_message, CGI.escapeHTML(@user.email)]
        redirect_to login_path
      end
    end
  end
  
  def activate
    respond_to do |format|
      format.html do
        self.current_user = User.find_by_login_key(params[:key])
        if logged_in? && !current_user.activated?
          current_user.toggle! :activated
          flash[:notice] = "Signup complete!"[:signup_complete_message]
        end
        redirect_to home_path
      end
    end
  end
  
  def update
    @user.attributes = params[:user]
    # temp fix to let people with dumb usernames change them
    @user.login = params[:user][:login] if not @user.valid? and @user.errors.on(:login)
    @user.save! and flash[:notice]="Your settings have been saved."[:settings_saved_message]
    respond_to do |format|
      format.html { redirect_to edit_user_path(@user) }
      format.xml  { head 200 }
    end
  end

  def admin
    respond_to do |format|
      format.html do
        @user.admin = params[:user][:admin] == '1'
        @user.save
        @user.forums << Forum.find(params[:moderator]) unless params[:moderator].blank? || params[:moderator] == '-'
        redirect_to user_path(@user)
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path }
      format.xml  { head 200 }
    end
  end

  protected
    def authorized?
      admin? || (!%w(destroy admin).include?(action_name) && (params[:id].nil? || params[:id] == current_user.id.to_s))
    end
    
    def find_user
      @user = params[:id] ? User.find_by_id(params[:id]) : current_user
    end
end
