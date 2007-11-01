require File.join(File.dirname(__FILE__), 'abstract_unit')

class ActiveRecordContextTest < Test::Unit::TestCase
  def setup
    Post.destroy_all
    @posts = []
    @topic = Topic.create! :title => 'test'
    @posts << NormalPost.create!(:body => 'normal body', :topic => @topic)
    @posts << PolymorphPost.create!(:body => 'polymorph body', :topic => @topic)
    assert_equal 2, @posts.size
    assert_equal 2, Post.count
    assert_nil Post.context_cache
  end

  def test_should_initialize_context_cache_hash
    Post.with_context do
      assert_kind_of Hash, Post.context_cache
      assert_equal 0, Post.context_cache.size
    end
    assert_nil Post.context_cache
  end

  def test_should_store_records_in_cache
    Post.with_context do
      records = Post.find(:all)
      assert_equal 2, Post.context_cache[Post].size
      assert_equal @posts[0], Post.cached[@posts[0].id]
      assert_equal @posts[1], Post.cached[@posts[1].id]
    end
  end

  def test_should_store_records_in_base_class_cache
    Post.with_context do
      records = NormalPost.find(:all)
      assert Post.context_cache[NormalPost].nil?
      assert_equal @posts[0], NormalPost.cached[@posts[0].id]
      assert_equal 1, Post.context_cache[Post].size
      assert_equal @posts[0], Post.cached[@posts[0].id]
    end
  end

  def test_should_find_records_in_context
    Post.with_context do
      records = Post.find(:all)
      Post.destroy_all
      assert_equal @posts[0], Post.find(@posts.first.id)
      assert_equal @posts[1], Post.find(@posts.last.id)
    end
    
    assert_raise ActiveRecord::RecordNotFound do
      Post.find 1
    end
  end
  
  def test_should_find_belongs_to_record
    Post.with_context do
      Topic.find :all ; Topic.delete_all
      assert_equal @topic, @posts[0].topic(true)
    end
    
    assert_equal @topic, @posts[0].topic
    assert_nil @posts[0].topic(true)
  end
  
  def test_should_find_belongs_to_polymorphic_record
    Post.with_context do
      Topic.find :all ; Topic.delete_all
      assert_equal @topic, @posts[1].topic(true)
    end
    
    assert_equal @topic, @posts[1].topic
    assert_nil @posts[1].topic(true)
  end
  
  def test_default_prefetch_methods
    {Topic => 'topic_id', Post => 'post_id'}.each do |klass, expected|
      assert_equal expected, klass.prefetch_default
    end
  end
  
  def test_should_prefetch_ids
    Topic.expects(:find).with(:all, :conditions => {:id => [1,2,3]})
    Topic.prefetch [1,2,3]
  end
  
  def test_should_prefetch_by_parent_records
    Topic.expects(:find).with(:all, :conditions => {:id => [@topic.id]})
    Topic.prefetch @posts
  end
  
  def test_should_reload_record
    Post.with_context do
      @post = Post.find @posts.first.id
      assert_equal 'normal body', @post.body
      Post.update_all ['body = ?', 'foo bar']
      assert_equal 'foo bar', @post.reload.body
    end
  end
end
