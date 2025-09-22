require 'test_helper'

class PostableNewRecordTest < ActiveSupport::TestCase
  test 'cover image methods should not error on new record' do
    post = Post.new(title: 'Test Post', user: users(:one))

    # These should not raise "Cannot get a signed_id for a new record" error
    assert_nil post.cover_image_thumbnail
    assert_nil post.cover_image_hero
    assert_nil post.cover_image_thumbnail_url
    assert_nil post.cover_image_hero_url

    # These should work normally
    assert_equal false, post.has_cover_image?
    assert_equal false, post.cover_image_variants_ready?
  end

  test 'cover image methods should work on persisted record without cover image' do
    post = Post.create!(title: 'Test Post', user: users(:one), slug: 'test-post')

    # These should not raise errors even on persisted records without cover images
    assert_nil post.cover_image_thumbnail
    assert_nil post.cover_image_hero
    assert_nil post.cover_image_thumbnail_url
    assert_nil post.cover_image_hero_url

    # These should work normally
    assert_equal false, post.has_cover_image?
    assert_equal false, post.cover_image_variants_ready?
  end
end
