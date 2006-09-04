class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy, :admin]
  before_filter :find_user,      :only => [:edit, :update, :destroy, :admin]

  def index
    @user_pages, @users = paginate(:users, :per_page => 50, :order => "display_name", :conditions => (params[:q] && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{params[:q]}%"}]))
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end
  
  def create
    @user = params[:user].blank? ? User.find_by_email(params[:email]) : User.new(params[:user])
    flash[:error] = "I could not find an account with the email address '#{CGI.escapeHTML params[:email]}'. Did you type it correctly?" if params[:email] and not @user
    redirect_to login_path and return unless @user
    @user.login = params[:user][:login] unless params[:user].blank?
    @user.reset_login_key! 
    UserMailer.deliver_signup(@user, request.host_with_port)
    flash[:notice] = "#{params[:user].blank? ? "An account activation" : "A temporary login"} email has been sent to '#{CGI.escapeHTML @user.email}'."
    redirect_to login_path
  end
  
  def activate
    self.current_user = User.find_by_login_key(params[:key])
    if logged_in? && !current_user.activated?
      current_user.toggle! :activated
      flash[:notice] = "Signup complete!"
    end
    redirect_to home_path
  end
  
  def update
    @user.attributes = params[:user]
    # temp fix to let people with dumb usernames change them
    @user.login = params[:user][:login] if not @user.valid? and @user.errors.on(:login)
    @user.save! and flash[:notice]="Your settings have been saved."
    redirect_to edit_user_path(@user)
  end

  def admin
    @user.admin = params[:user][:admin] == '1'
    @user.save
    @user.forums << Forum.find(params[:moderator]) unless params[:moderator].blank? || params[:moderator] == '-'
    redirect_to user_path(@user)
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  protected
    def authorized?
      admin? || (!%w(destroy admin).include?(action_name) && (params[:id].nil? || params[:id] == current_user.id.to_s))
    end
    
    def find_user
      @user = params[:id] ? User.find_by_id(params[:id]) : current_user
    end
end
