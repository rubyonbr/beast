ActionController::Routing::Routes.draw do |map|
  map.home '', :controller => 'forums', :action => 'index'

  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session
  
  map.resources :users, :member => { :admin => :post }, :has_many => [:moderators, :posts]
  
  map.resources :forums, :has_many => [:posts] do |forum|
    forum.resources :topics, :name_prefix => nil do |topic|
      topic.resources :posts, :name_prefix => nil
      topic.resource :monitorship, :name_prefix => nil
    end
  end

  map.resources :posts, :name_prefix => 'all_', :collection => { :search => :get }

  map.with_options :controller => 'users' do |user|
    user.signup   'signup',        :action => 'new'
    user.settings 'settings',      :action => 'edit'
    user.activate 'activate/:key', :action => 'activate'
  end
  
  map.with_options :controller => 'sessions' do |session|
    session.login    'login',  :action => 'new'
    session.logout   'logout', :action => 'destroy'
  end

  map.with_options :controller => 'posts', :action => 'monitored' do |map|
    map.formatted_monitored_posts 'users/:user_id/monitored.:format'
    map.monitored_posts           'users/:user_id/monitored'
  end

  map.exceptions 'logged_exceptions/:action/:id', :controller => 'logged_exceptions', :action => 'index', :id => nil
end
