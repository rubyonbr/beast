class ForumsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :find_or_initialize_forum, :except => :index

  def index
    @forums = Forum.find(:all, :order => "position")
  end

  def show
    # keep track of when we last viewed this forum for activity indicators
    (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?
    @topic_pages, @topics = paginate(:topics, :per_page => 25, :conditions => ['forum_id = ?', params[:id]], :include => :replied_by_user, :order => 'sticky desc, replied_at desc')
  end

  # new renders new.rhtml
  
  # we're cheating a bit, but create/new are essentially the same thing
  def update
    @forum.attributes = params[:forum]
    @forum.save!
    redirect_to forums_path
  end
  alias create update
  
  def destroy
    @forum.destroy
    redirect_to forums_path
  end
  
  protected
    def find_or_initialize_forum() @forum = params[:id] ? Forum.find(params[:id]) : Forum.new end
    alias authorized? admin?
end
