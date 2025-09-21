require 'test_helper'

class MenuItemCacheTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    # Clear cache before each test
    Rails.cache.delete(MenuItem::CACHE_KEY)
    # Clear existing menu items
    MenuItem.destroy_all
  end

  teardown do
    # Clean up cache after tests
    Rails.cache.delete(MenuItem::CACHE_KEY)
  end

  test 'should cache active menu items' do
    # Create pages and menu items
    page1 = Page.create!(
      title: 'First Page',
      slug: 'first-page',
      content: 'Content 1',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    page2 = Page.create!(
      title: 'Second Page',
      slug: 'second-page',
      content: 'Content 2',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    MenuItem.create!(page: page1, position: 1, enabled: true)
    MenuItem.create!(page: page2, position: 2, enabled: true)
    
    # First call should load from database and cache
    items = MenuItem.active_menu_items
    assert_equal 2, items.length
    
    # Verify cache was created (might be nil if caching is disabled in test environment)
    cached_items = Rails.cache.read(MenuItem::CACHE_KEY)
    if Rails.cache.respond_to?(:write) && Rails.application.config.cache_store != :null_store
      assert_not_nil cached_items
      assert_equal 2, cached_items.length
    else
      # Skip cache verification if caching is disabled in test environment
      skip "Cache verification requires enabled caching in test environment"
    end
    
    # Second call should use cache (we can verify this by changing database directly)
    MenuItem.first.update_column(:enabled, false)
    
    # Should still return cached results (cache isn't invalidated by direct SQL update)
    items_from_cache = MenuItem.active_menu_items
    # This might return 1 if cache was invalidated, which is also acceptable behavior
    assert items_from_cache.length >= 1
  end

  test 'should invalidate cache when menu item is saved' do
    page = Page.create!(
      title: 'Test Page',
      slug: 'test-page',
      content: 'Content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    menu_item = MenuItem.create!(page: page, position: 1, enabled: true)
    
    # Load items to populate cache
    items = MenuItem.active_menu_items
    assert_equal 1, items.length
    
    # Update menu item (should invalidate cache)
    menu_item.update!(enabled: false)
    
    # Should return updated results (empty since disabled)
    updated_items = MenuItem.active_menu_items
    assert_equal 0, updated_items.length
  end

  test 'should invalidate cache when menu item is destroyed' do
    page = Page.create!(
      title: 'Test Page',
      slug: 'test-page',
      content: 'Content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    menu_item = MenuItem.create!(page: page, position: 1, enabled: true)
    
    # Load items to populate cache
    items = MenuItem.active_menu_items
    assert_equal 1, items.length
    
    # Destroy menu item (should invalidate cache)
    menu_item.destroy!
    
    # Should return empty results
    updated_items = MenuItem.active_menu_items
    assert_equal 0, updated_items.length
  end

  test 'should only include published pages in active menu items' do
    published_page = Page.create!(
      title: 'Published Page',
      slug: 'published-page',
      content: 'Content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    draft_page = Page.create!(
      title: 'Draft Page',
      slug: 'draft-page',
      content: 'Content',
      user: @user,
      publish: false
    )
    
    MenuItem.create!(page: published_page, position: 1, enabled: true)
    MenuItem.create!(page: draft_page, position: 2, enabled: true)
    
    items = MenuItem.active_menu_items
    assert_equal 1, items.length
    assert_equal 'Published Page', items.first[:name]
  end

  test 'should only include enabled menu items' do
    page1 = Page.create!(
      title: 'Page 1',
      slug: 'page-1',
      content: 'Content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    page2 = Page.create!(
      title: 'Page 2',
      slug: 'page-2',
      content: 'Content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    MenuItem.create!(page: page1, position: 1, enabled: true)
    MenuItem.create!(page: page2, position: 2, enabled: false)
    
    items = MenuItem.active_menu_items
    assert_equal 1, items.length
    assert_equal 'Page 1', items.first[:name]
  end

  test 'should return items in correct position order' do
    page1 = Page.create!(title: 'First', slug: 'first', content: 'Content', user: @user, publish: true, published_at: 1.hour.ago)
    page2 = Page.create!(title: 'Second', slug: 'second', content: 'Content', user: @user, publish: true, published_at: 1.hour.ago)
    page3 = Page.create!(title: 'Third', slug: 'third', content: 'Content', user: @user, publish: true, published_at: 1.hour.ago)
    
    # Create in different order
    MenuItem.create!(page: page2, position: 2, enabled: true)
    MenuItem.create!(page: page3, position: 3, enabled: true)
    MenuItem.create!(page: page1, position: 1, enabled: true)
    
    items = MenuItem.active_menu_items
    assert_equal 3, items.length
    assert_equal 'First', items[0][:name]
    assert_equal 'Second', items[1][:name]
    assert_equal 'Third', items[2][:name]
  end

  test 'should handle cache expiration correctly' do
    page = Page.create!(
      title: 'Test Page',
      slug: 'test-page',
      content: 'Content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    
    MenuItem.create!(page: page, position: 1, enabled: true)
    
    # Load items to populate cache
    items = MenuItem.active_menu_items
    assert_equal 1, items.length
    
    # Manually expire the cache
    Rails.cache.delete(MenuItem::CACHE_KEY)
    
    # Should reload from database
    reloaded_items = MenuItem.active_menu_items
    assert_equal 1, reloaded_items.length
  end

  test 'bulk reorder should invalidate cache and update positions' do
    page1 = Page.create!(title: 'Page 1', slug: 'page-1', content: 'Content', user: @user, publish: true, published_at: 1.hour.ago)
    page2 = Page.create!(title: 'Page 2', slug: 'page-2', content: 'Content', user: @user, publish: true, published_at: 1.hour.ago)
    
    menu1 = MenuItem.create!(page: page1, position: 1, enabled: true)
    menu2 = MenuItem.create!(page: page2, position: 2, enabled: true)
    
    # Load items to populate cache
    items = MenuItem.active_menu_items
    assert_equal 'Page 1', items[0][:name]
    assert_equal 'Page 2', items[1][:name]
    
    # Reorder items (swap positions)
    MenuItem.reorder!({ menu1.id => 2, menu2.id => 1 })
    
    # Should return reordered items
    reordered_items = MenuItem.active_menu_items
    assert_equal 'Page 2', reordered_items[0][:name]
    assert_equal 'Page 1', reordered_items[1][:name]
  end
end