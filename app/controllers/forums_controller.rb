class ForumsController < ApplicationController
  before_filter :login_required, :except => [ :index, :show ]
  before_filter :find_or_initialize_forum, :except => :index

  cache_sweeper :posts_sweeper, :only => [:create, :update, :destroy]

  def index
    @forums = Forum.find(:all, :order => "position")
    # reset the page of each forum we have visited when we go back to index
    session[:forum_page]=nil
    respond_to do |format|
      format.html
      format.xml { render :xml => @forums.to_xml }
    end
  end

  def show
    respond_to do |format|
      format.html do
        # keep track of when we last viewed this forum for activity indicators
        (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?
        (session[:forum_page] ||= Hash.new(1))[@forum.id] = params[:page].to_i if params[:page]
        @topics = @forum.topics.paginate :page => params[:page], :include => :replied_by_user
      end
      format.xml { render :xml => @forum.to_xml }
    end
  end

  # new renders new.html.erb
  
  def create
    @forum.attributes = params[:forum]
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head :created, :location => formatted_forum_url(@forum, :xml) }
    end
  end

  def update
    @forum.update_attributes!(params[:forum])
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head 200 }
    end
  end
  
  protected
    def find_or_initialize_forum
      @forum = params[:id] ? Forum.find(params[:id]) : Forum.new
    end

    alias authorized? admin?
end
