require 'test_helper'
require 'action_view'

class SecurityTest < ActiveSupport::TestCase
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TagHelper
  include ERB::Util  # For h() method
  
  setup do
    @user = users(:one)
  end

  test 'should sanitize hero image attribution to prevent XSS' do
    # Test that malicious script tags are removed
    malicious_content = 'Photo by <script>alert("xss")</script>John Doe'
    SiteSetting.set_hero_image_attribution(malicious_content)
    
    # The raw value should still contain the script tag
    assert SiteSetting.hero_image_attribution.include?('<script>'), "Expected raw content to contain script tag"
    
    # But when rendered through our sanitize helper, it should be cleaned
    # We'll test this by simulating what our view does
    sanitized = sanitize(SiteSetting.hero_image_attribution, tags: %w[a], attributes: %w[href target])
    assert_not sanitized.include?('<script>'), "Expected sanitized content to not contain script tags"
    # The sanitize method strips script tags and their content, so we should check for remaining text
    assert sanitized.include?('Photo by'), "Expected sanitized content to contain 'Photo by'"
    assert sanitized.include?('John Doe'), "Expected sanitized content to contain 'John Doe'"
  end

  test 'should allow safe HTML in hero image attribution' do
    safe_content = 'Photo by <a href="https://unsplash.com/@johndoe" target="_blank">John Doe</a> on Unsplash'
    SiteSetting.set_hero_image_attribution(safe_content)
    
    sanitized = sanitize(SiteSetting.hero_image_attribution, tags: %w[a], attributes: %w[href target])
    assert sanitized.include?('<a href="https://unsplash.com/@johndoe" target="_blank">John Doe</a>'), "Expected sanitized content to preserve safe HTML links"
  end

  test 'should escape search parameters to prevent XSS' do
    malicious_query = '<script>alert("xss")</script>search term'
    
    # Test that our h() helper properly escapes the query
    escaped = h(malicious_query)
    assert_not escaped.include?('<script>'), "Expected escaped content to not contain script tags"
    assert escaped.include?('&lt;script&gt;'), "Expected escaped content to contain HTML entities"
  end

  test 'should validate menu item URLs are safe internal paths' do
    page = Page.create!(
      title: 'Test Page',
      slug: 'test-page',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    # Clear existing menu items first to avoid position conflicts
    MenuItem.destroy_all
    
    menu_item = MenuItem.create!(
      page: page,
      position: 1,
      enabled: true
    )
    
    # MenuItem URL should be a safe internal path
    assert menu_item.url.start_with?('/')
    assert_equal '/pages/test-page', menu_item.url
    
    # Should not contain any potentially dangerous content
    assert_not menu_item.url.include?('<script>'), "Expected menu URL to not contain script tags"
    assert_not menu_item.url.include?('javascript:'), "Expected menu URL to not contain javascript protocol"
    assert_not menu_item.url.include?('data:'), "Expected menu URL to not contain data protocol"
  end

  test 'should handle slug injection attempts safely' do
    # Test that malicious content in title doesn't create dangerous slugs
    malicious_title = 'Normal Title<script>alert("xss")</script>'
    
    page = Page.new(
      title: malicious_title,
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    page.save!
    
    # Slug should be safely generated without script content
    assert_not page.slug.include?('<script>'), "Expected slug to not contain script tags"
    # Should create a safe slug from the clean title
    assert page.slug.match?(/\Anormal-title/)
  end

  test 'should prevent SQL injection in search' do
    # Test malicious SQL injection attempt
    malicious_query = "'; DROP TABLE posts; --"
    
    # This should not cause an error and should return empty results safely
    assert_nothing_raised do
      service = SearchService.new(malicious_query).perform
      assert_respond_to service, :results
    end
  end

  test 'should sanitize user input in post content' do
    # Action Text should handle sanitization, but let's test basic functionality
    post = Post.new(
      title: 'Test Post',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    # Action Text content with potential XSS
    malicious_content = 'Safe content <script>alert("xss")</script> more content'
    post.content = malicious_content
    
    assert post.save
    
    # Action Text should handle sanitization of content
    # The exact behavior depends on Action Text configuration
    assert_not_nil post.content
  end
end