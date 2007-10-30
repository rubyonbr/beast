class SessionsController < ApplicationController
  def create
    if using_open_id?
      cookies[:use_open_id] = {:value => '1', :expires => 1.year.from_now.utc}
      open_id_authentication
    else
      cookies[:use_open_id] = {:value => '0', :expires => 1.year.ago.utc}
      password_authentication params[:login], params[:password]
    end
  end
  
  def destroy
    session.delete
    cookies.delete :login_token
    flash[:notice] = "You have been logged out."[:logged_out_message]
    redirect_to CGI.unescape(params[:to] || home_path)
  end

  protected
    def open_id_authentication
      authenticate_with_open_id params[:openid_url] do |result, openid_url|
        if result.successful?
          if self.current_user = User.find_by_openid_url(openid_url)
            successful_login
          else
            failed_login "Sorry, no user by the identity URL {openid_url} exists"[:openid_no_user_message, openid_url.inspect]
          end
        else
          failed_login result.message
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
      cookies[:login_token] = {:value => "#{current_user.id};#{current_user.active_login_key}", :expires => 1.year.from_now.utc} if params[:remember_me] == "1"
      redirect_to CGI.unescape(params[:to] || home_path)
    end

    def failed_login(message)
      flash.now[:error] = message
      render :action => 'new'
    end
    
    def root_url() home_url; end
    
  private
    def open_id_redirect_url(open_id_response)
      return_to = "#{request.protocol + request.host_with_port + request.path}?open_id_complete=1"
      return_to << "&to=#{params[:to]}" unless params[:to].blank?
      open_id_response.redirect_url(
        request.protocol + request.host_with_port + "/",
        open_id_response.return_to(return_to)
      )     
    end
end
