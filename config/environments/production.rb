# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

config.after_initialize do
  require 'application' unless Object.const_defined?(:ApplicationController)
  LoggedExceptionsController.class_eval do
    session :session_key => '_beast_session_id'
    include AuthenticationSystem
    before_filter :login_required
    self.application_name = "Beast"
    
    protected
      alias admin? authorized?
      
      # modify beast's login required to accept http basic auth
      def login_required_with_basic
        respond_to do |accepts|
          accepts.html { login_required_without_basic }
          accepts.js { login_required_without_basic }
          accepts.rss do
            access_denied_with_basic_auth unless self.current_user = User.authenticate(*get_auth_data)
          end
        end
      end
      
      alias_method_chain :login_required, :basic
  end
end