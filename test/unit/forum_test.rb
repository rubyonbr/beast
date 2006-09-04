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
end
