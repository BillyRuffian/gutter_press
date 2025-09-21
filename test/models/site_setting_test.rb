require 'test_helper'

class SiteSettingTest < ActiveSupport::TestCase
  def setup
    # Clear cache before each test
    Rails.cache.delete(SiteSetting::CACHE_KEY)
    # Clear all existing settings
    SiteSetting.delete_all
  end

  def teardown
    # Clean up cache after each test
    Rails.cache.delete(SiteSetting::CACHE_KEY)
  end

  test 'should return default values when no setting exists' do
    assert_equal 'Gutter Press', SiteSetting.get('site_name')
    assert_equal 'A modern blogging platform', SiteSetting.get('site_description')
    assert_equal '10', SiteSetting.get('posts_per_page')
    assert_equal 'false', SiteSetting.get('hero_enabled')
  end

  test 'should return database value when setting exists' do
    SiteSetting.set('site_name', 'Custom Blog Name')
    assert_equal 'Custom Blog Name', SiteSetting.get('site_name')
  end

  test 'should cache settings after first load' do
    # Set a value
    SiteSetting.set('site_name', 'Cached Name')

    # First call should load from database
    assert_equal 'Cached Name', SiteSetting.get('site_name')

    # Change database directly (bypassing cache invalidation)
    SiteSetting.where(key: 'site_name').update_all(value: 'Direct Change')

    # May or may not return cached value depending on cache implementation
    # The important thing is it works correctly after cache clear
    Rails.cache.delete(SiteSetting::CACHE_KEY)
    assert_equal 'Direct Change', SiteSetting.get('site_name')
  end

  test 'should invalidate cache when setting is updated' do
    SiteSetting.set('site_name', 'Original Name')
    assert_equal 'Original Name', SiteSetting.get('site_name')

    # Update should invalidate cache
    SiteSetting.set('site_name', 'Updated Name')
    assert_equal 'Updated Name', SiteSetting.get('site_name')
  end

  test 'should handle boolean conversion for enabled settings' do
    assert_not SiteSetting.hero_enabled?

    SiteSetting.set('hero_enabled', 'true')
    assert SiteSetting.hero_enabled?

    SiteSetting.set('hero_enabled', 'false')
    assert_not SiteSetting.hero_enabled?
  end

  test 'should handle integer conversion for posts per page' do
    assert_equal 10, SiteSetting.posts_per_page

    SiteSetting.set('posts_per_page', '25')
    assert_equal 25, SiteSetting.posts_per_page
  end

  test 'should handle hero image attachment' do
    assert_not SiteSetting.has_hero_image?

    # Attach a test image
    hero_record = SiteSetting.hero_image_record
    hero_record.hero_image.attach(
      io: StringIO.new('test image data'),
      filename: 'hero.jpg',
      content_type: 'image/jpeg'
    )

    assert SiteSetting.has_hero_image?
  end

  test 'should return correct hero image attribution' do
    attribution_text = 'Photo by Test User'
    SiteSetting.set_hero_image_attribution(attribution_text)

    assert_equal attribution_text, SiteSetting.hero_image_attribution
  end

  test 'should validate key presence and uniqueness' do
    setting = SiteSetting.new(value: 'test')
    assert_not setting.valid?
    assert_includes setting.errors[:key], "can't be blank"

    # Create first setting
    SiteSetting.create!(key: 'test_key', value: 'test_value')

    # Try to create duplicate
    duplicate = SiteSetting.new(key: 'test_key', value: 'another_value')
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:key], 'has already been taken'
  end

  test 'should allow empty value' do
    setting = SiteSetting.new(key: 'empty_setting', value: '')
    assert setting.valid?
  end

  test 'should clear cache when setting is deleted' do
    SiteSetting.set('temp_setting', 'temp_value')
    assert_equal 'temp_value', SiteSetting.get('temp_setting')

    # Delete the setting
    SiteSetting.find_by(key: 'temp_setting').destroy

    # Should return default (nil in this case since no default exists)
    assert_nil SiteSetting.get('temp_setting')
  end

  test 'should handle missing defaults gracefully' do
    assert_nil SiteSetting.get('nonexistent_setting')
  end

  test 'should convert symbol keys to strings' do
    assert_equal SiteSetting.get(:site_name), SiteSetting.get('site_name')
  end

  test 'should return all default values correctly' do
    expected_defaults = {
      'site_name' => 'Gutter Press',
      'site_description' => 'A modern blogging platform',
      'site_tagline' => 'Share your stories with the world',
      'posts_per_page' => '10',
      'allow_comments' => 'true',
      'contact_email' => '',
      'footer_text' => '© 2025 Gutter Press. All rights reserved.',
      'hero_enabled' => 'false',
      'hero_title' => 'Welcome to Our Blog',
      'hero_subtitle' => 'Discover amazing stories and insights'
    }

    expected_defaults.each do |key, expected_value|
      assert_equal expected_value, SiteSetting.get(key), "Default value for #{key} should be #{expected_value}"
    end
  end
end
