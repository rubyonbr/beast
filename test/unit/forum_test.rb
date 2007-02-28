require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < Test::Unit::TestCase
  all_fixtures

  def test_should_list_only_top_level_topics
    assert_models_equal [topics(:sticky), topics(:il8n), topics(:ponies), topics(:pdi)], forums(:rails).topics
  end

  def test_should_list_recent_posts
    assert_models_equal [posts(:il8n), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi),posts(:sticky) ], forums(:rails).posts
  end

  def test_should_find_last_post
    assert_equal posts(:il8n), forums(:rails).posts.last
  end

  def test_should_find_first_topic
    assert_equal topics(:sticky), forums(:rails).topics.first
  end

  def test_should_find_first_recent_post
    assert_equal topics(:il8n), forums(:rails).recent_topics.first
  end


  def test_should_format_body_html
    forum = Forum.new(:description => 'foo')
    forum.send :format_content
    assert_not_nil forum.description_html
    
    forum.description = ''
    forum.send :format_content
    assert forum.description_html.blank?
  end
end
