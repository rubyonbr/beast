class PostsController < ApplicationController
  before_filter :find_post,      :except => [:index, :create, :monitored]
  before_filter :login_required, :except => [:index, :monitored]
  before_filter(:only => [:index, :monitored]) { |c| c.params[:page] = 1 if c.params[:format] == 'rss' }

  def index
    conditions = []
    [:user_id, :forum_id].each { |attr| conditions << Post.send(:sanitize_sql, ["posts.#{attr} = ?", params[attr]]) if params[attr] }
    conditions << Post.send(:sanitize_sql, ['LOWER(posts.body) LIKE ?', "%#{params[:q]}%"]) unless params[:q].blank?
    @post_pages, @posts = paginate(:posts, :per_page => 25, :select => 'posts.*, topics.title as topic_title', :joins => 'inner join topics on posts.topic_id = topics.id',
      :conditions => conditions.any? ? conditions.collect { |c| "(#{c})" }.join(' AND ') : nil, :order => 'posts.created_at desc, posts.id desc')
    render_posts_or_xml
  end

  def monitored
    @user = User.find params[:user_id]
    @post_pages, @posts = paginate(:posts, :per_page => 25, :select => 'posts.*, topics.title as topic_title', :joins => 'inner join topics on posts.topic_id = topics.id inner join monitorships on monitorships.topic_id = topics.id',
      :conditions => ['monitorships.user_id = ? and posts.user_id != ?', params[:user_id], @user.id], :order => 'posts.created_at desc, posts.id desc')
    render_posts_or_xml
  end

  def create
    @topic = Topic.find_by_id_and_forum_id(params[:topic_id],params[:forum_id], :include => :forum)
    if @topic.locked?
      flash[:notice] = 'This topic is locked.'
      return redirect_to(topic_path(:forum_id => params[:forum_id], :id => params[:topic_id]))
    end
    @forum = @topic.forum
    @post  = @topic.posts.build(params[:post])
    @post.user = current_user
    @post.save!
    redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'Please post something at least...'
    redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => 'reply-form', :page => params[:page] || '1')
  end
  
  def edit
    respond_to { |format| format.html; format.js }
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = 'An error occurred'
  ensure
    respond_to do |format|
      format.html do
        redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => @post.dom_id, :page => params[:page] || '1')
      end
      format.js 
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = "Post of '#{CGI::escapeHTML @post.topic.title}' was deleted."
    # check for posts_count == 1 because its cached and counting the currently deleted post
    @post.topic.destroy and redirect_to forum_path(params[:forum_id]) if @post.topic.posts_count == 1
    redirect_to topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :page => params[:page]) unless performed?
  end

  protected
    def authorized?
      action_name == 'create' || @post.editable_by?(current_user)
    end
    
    def find_post
      @post = Post.find_by_id_and_topic_id_and_forum_id(params[:id], params[:topic_id], params[:forum_id]) || raise(ActiveRecord::RecordNotFound)
    end
    
    def render_posts_or_xml
      respond_to do |format|
        format.html
        format.rss { render :action => "#{action_name}.rxml", :layout => false }
      end
    end
end
