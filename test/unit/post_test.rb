require File.dirname(__FILE__) + '/../test_helper'

class PostTest < Test::Unit::TestCase
  all_fixtures

  def test_should_select_posts
    assert_equal [posts(:pdi), posts(:pdi_reply), posts(:pdi_rebuttal)], topics(:pdi).posts
  end
  
  def test_should_find_topic
    assert_equal topics(:pdi), posts(:pdi_reply).topic
  end

  def test_should_require_body_for_post
    p = topics(:pdi).posts.build
    p.valid?
    assert p.errors.on(:body)
  end

  def test_should_create_reply
    counts = lambda { [Post.count, forums(:rails).posts_count, users(:aaron).posts_count, topics(:pdi).posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call
    
    p = create_post topics(:pdi), :body => 'blah'
    assert_valid p

    [forums(:rails), users(:aaron), topics(:pdi)].each &:reload
    
    assert_equal old_counts.collect { |n| n + 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_update_cached_data
    p = create_post topics(:pdi), :body => 'ok, ill get right on it'
    assert_valid p
    topics(:pdi).reload
    assert_equal p.id, topics(:pdi).last_post_id
    assert_equal p.user_id, topics(:pdi).replied_by
    assert_equal p.created_at.to_i, topics(:pdi).replied_at.to_i
  end

  def test_should_delete_last_post_and_fix_topic_cached_data
    posts(:pdi_rebuttal).destroy
    assert_equal posts(:pdi_reply).id, topics(:pdi).last_post_id
    assert_equal posts(:pdi_reply).user_id, topics(:pdi).replied_by
    assert_equal posts(:pdi_reply).created_at.to_i, topics(:pdi).replied_at.to_i
  end

  def test_should_create_reply_and_set_forum_from_topic
    p = create_post topics(:pdi), :body => 'blah'
    assert_equal topics(:pdi).forum_id, p.forum_id
  end

  def test_should_delete_reply
    counts = lambda { [Post.count, forums(:rails).posts_count, users(:sam).posts_count, topics(:pdi).posts_count] }
    equal  = lambda { [forums(:rails).topics_count] }
    old_counts = counts.call
    old_equal  = equal.call
    posts(:pdi_reply).destroy
    [forums(:rails), users(:sam), topics(:pdi)].each &:reload
    assert_equal old_counts.collect { |n| n - 1}, counts.call
    assert_equal old_equal, equal.call
  end

  def test_should_edit_own_post
    assert posts(:shield).editable_by?(users(:sam))
  end

  def test_should_edit_post_as_admin
    assert posts(:shield).editable_by?(users(:aaron))
  end

  def test_should_edit_post_as_moderator
    assert posts(:pdi).editable_by?(users(:sam))
  end

  def test_should_not_edit_post_in_own_topic
    assert !posts(:shield_reply).editable_by?(users(:sam))
  end

  protected
    def create_post(topic, options = {})
      returning topic.posts.build(options) do |p|
        p.user = users(:aaron)
        p.save
        # post should inherit the forum from the topic
        assert_equal p.topic.forum, p.forum
      end
    end
end
