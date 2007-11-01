class ApplicationController < ActionController::Base
  init_gettext "beast" if Object.const_defined?(:GetText)

  include ExceptionLoggable, BrowserFilters, AuthenticationSystem
  session :session_key => '_beast_session_id'

  helper_method :current_user, :logged_in?, :admin?, :last_active
  before_filter :login_by_token
  around_filter :set_context

  protected
    def set_context
      ActiveRecord::Base.with_context do
        yield
      end
    end

    def last_active
      session[:last_active] ||= Time.now.utc
    end
    
    def rescue_action(exception)
      exception.is_a?(ActiveRecord::RecordInvalid) ? render_invalid_record(exception.record) : super
    end

    def render_invalid_record(record)
      render :action => (record.new_record? ? 'new' : 'edit')
    end
end
