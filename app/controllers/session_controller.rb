class SessionController < ApplicationController

  def create
    if open_id?(params[:login])
      open_id_authentication params[:login]
    else
      password_authentication params[:login], params[:password]
    end
  end
  
  def destroy
    session.delete
    cookies.delete :login_token
    flash[:notice] = "You have been logged out."[:logged_out_message]
    redirect_to home_path
  end

  protected
    def open_id_authentication(identity_url)
      authenticate_with_open_id(identity_url, :required => [:nickname, :email], :optional => :fullname) do |status, identity_url, registration|
        case status
        when :missing
          failed_login "Sorry, the OpenID server couldn't be found"[:openid_not_found_message]
        when :canceled
          failed_login "OpenID verification was canceled"[:openid_canceled_message]
        when :failed
          failed_login "Sorry, the OpenID verification failed"[:openid_failed_message]
        when :successful
          if self.current_user = User.find_or_initialize_by_identity_url(identity_url)
            {'login=' => 'nickname', 'email=' => 'email', 'display_name=' => 'fullname'}.each do |attr, reg|
              current_user.send(attr, registration[reg]) unless registration[reg].blank?
            end
            unless current_user.save
              flash[:error] = "Error saving the fields from your OpenID profile at {identity_url}: {errors}"[:openid_saving_error_message, identity_url.inspect, current_user.errors.full_messages.to_sentence]
            end
            successful_login
          else
            failed_login "Sorry, no user by the identity URL {identity_url} exists"[:openid_no_user_message, identity_url.inspect]
          end
        end
      end
    end

    def password_authentication(name, password)
      if self.current_user = User.authenticate(name, password)
        successful_login
      else
        failed_login "Invalid login or password, try again please."[:invalid_login_message]
      end
    end

    def successful_login
      cookies[:login_token]= {:value => "#{current_user.id};#{current_user.reset_login_key!}", :expires => Time.now.utc+1.year} if params[:remember_me] == "1"
      redirect_to home_path
    end

    def failed_login(message)
      flash.now[:error] = message
      render :action => 'new'
    end
    
    def root_url() home_url; end
end
