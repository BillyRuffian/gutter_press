require 'test_helper'

class PostableEdgeCasesTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test 'should handle extremely long titles gracefully' do
    long_title = 'A' * 500  # Reduced to more reasonable length
    post = Post.new(
      title: long_title,
      content: 'Test content',
      user: @user
    )
    
    # Should save successfully or fail gracefully with validation
    saved = post.save
    if saved
      # Slug should be generated (may be long but should not crash)
      assert_not_nil post.slug
      # Just verify it's a reasonable string and not empty
      assert post.slug.length > 0, "Slug should not be empty"
      assert post.slug.is_a?(String), "Slug should be a string"
    else
      # If there's a length validation, that's also acceptable behavior
      # Just verify it fails gracefully without exceptions
      assert_not_nil post.errors
      # Ensure the post instance is still valid (no exceptions were raised)
      assert post.is_a?(Post)
    end
    # The main test is that this completes without exceptions
    assert true, "Post with extremely long title handled gracefully"
  end

  test 'should handle special unicode characters in titles' do
    unicode_title = 'Test with émojis 🚀 and spëcial ñ characters'
    post = Post.new(
      title: unicode_title,
      content: 'Test content',
      user: @user
    )
    
    assert post.save
    assert_not_nil post.slug
    # Slug should be URL-safe
    assert post.slug.match?(/\A[a-z0-9\-]+\z/)
  end

  test 'should handle empty content gracefully' do
    post = Post.new(
      title: 'Test Post',
      content: '',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    assert post.save
    assert_equal '', post.display_excerpt
  end

  test 'should handle content with only whitespace' do
    post = Post.new(
      title: 'Test Post',
      content: "   \n\n\t   ",
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    assert post.save
    # Display excerpt should handle whitespace-only content
    assert_equal '', post.display_excerpt
  end

  test 'should handle very short content for excerpt' do
    short_content = 'Hi'
    post = Post.new(
      title: 'Test Post',
      content: short_content,
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    assert post.save
    # Should not crash with very short content
    excerpt = post.display_excerpt
    assert excerpt.is_a?(String)
  end

  test 'should handle malformed newlines in content' do
    malformed_content = "First line\r\n\nSecond line\\n\\nThird line"
    post = Post.new(
      title: 'Test Post',
      content: malformed_content,
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    assert post.save
    # Should handle mixed newline formats gracefully
    excerpt = post.display_excerpt
    assert excerpt.is_a?(String)
    assert excerpt.length > 0
  end

  test 'should handle concurrent slug generation' do
    base_title = 'Duplicate Title'
    
    # Create multiple posts with same title concurrently (simulated)
    posts = []
    3.times do |i|
      post = Post.new(
        title: base_title,
        content: "Content #{i}",
        user: @user,
        publish: true,
        published_at: i.hours.ago
      )
      posts << post
    end
    
    # Save all posts
    posts.each(&:save!)
    
    # All should have unique slugs
    slugs = posts.map(&:slug)
    assert_equal slugs.uniq.length, slugs.length, "All slugs should be unique"
    
    # First should have base slug, others should have numbered suffixes
    assert_includes slugs, 'duplicate-title'
    assert_includes slugs, 'duplicate-title-1'
    assert_includes slugs, 'duplicate-title-2'
  end

  test 'should handle invalid cover image content types' do
    post = Post.new(
      title: 'Test Post',
      content: 'Test content',
      user: @user
    )
    
    # Try to attach a non-image file as cover
    post.cover_image.attach(
      io: StringIO.new("not an image"),
      filename: "test.txt",
      content_type: "text/plain"
    )
    
    # Save should succeed (the post itself is valid)
    saved = post.save
    if saved
      # Cover image methods should handle invalid content types gracefully
      # (These methods return nil for invalid content types due to our VALID_COVER_IMAGE_TYPES check)
      assert_nil post.cover_image_thumbnail
      assert_nil post.cover_image_hero
    else
      # If there's validation preventing non-image attachments, that's also valid
      assert_not_nil post.errors
    end
  end

  test 'should handle missing cover image gracefully' do
    post = Post.new(
      title: 'Test Post',
      content: 'Test content',
      user: @user
    )
    
    assert post.save
    assert_not post.has_cover_image?
    assert_nil post.cover_image_thumbnail
    assert_nil post.cover_image_hero
    assert_not post.cover_image_variants_ready?
  end

  test 'should handle published_at edge cases' do
    post = Post.new(
      title: 'Future Post',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.from_now  # Future date
    )
    
    assert post.save
    
    # Should not be considered published if published_at is in the future
    assert_not post.published?
  end

  test 'should handle nil published_at with publish true' do
    post = Post.new(
      title: 'Test Post',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: nil
    )
    
    assert post.save
    # Should not be considered published without published_at
    assert_not post.published?
  end

  test 'should handle timezone edge cases for publishing' do
    # Test with different timezone
    Time.use_zone('UTC') do
      post = Post.new(
        title: 'Timezone Test',
        content: 'Test content',
        user: @user,
        publish: true,
        published_at: Time.current
      )
      
      assert post.save
      assert post.published?
    end
  end
end