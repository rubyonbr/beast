require "#{File.dirname(__FILE__)}/../test_helper"

class NewUserFirstPostTest < ActionController::IntegrationTest
  all_fixtures
  
  def setup
    ActionController::Base.perform_caching = true
  end
  
  def teardown
    ActionController::Base.perform_caching = false
  end
  
  def test_should_cache_posts_rss
    assert_cached "posts.rss" do
      get formatted_all_posts_path(:rss)
    end
  end
  
  def test_should_cache_forum_posts_rss
    assert_cached "forums/1/posts.rss" do
      get formatted_forum_posts_path(1, :rss)
    end
  end
  
  def test_should_cache_topic_posts_rss
    assert_cached "forums/1/topics/1/posts.rss" do
      get formatted_posts_path(1, 1, :rss)
    end
  end
  
  def test_should_cache_monitored_posts
    assert_cached "users/1/monitored.rss" do
      get formatted_monitored_posts_path(1, :rss)
    end
  end
  
  def assert_cached(path)
    path = File.join(RAILS_ROOT, 'public', path)
    yield
    assert File.exist?(path), "oops, not cached in: #{path.inspect}"
    FileUtils.rm_rf path
  end
end