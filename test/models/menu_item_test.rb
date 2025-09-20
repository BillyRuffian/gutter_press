require 'test_helper'
require 'minitest/mock'

class MenuItemTest < ActiveSupport::TestCase
  def setup
    MenuItem.invalidate_menu_cache
  end

  test 'should be valid with valid attributes' do
    # Clear existing items to avoid uniqueness conflicts
    MenuItem.destroy_all

    page = postables(:three) # Published Test Page
    menu_item = MenuItem.new(
      page: page,
      position: 1,
      enabled: true
    )
    assert menu_item.valid?
  end

  test 'should require page' do
    menu_item = MenuItem.new(position: 1, enabled: true)
    assert_not menu_item.valid?
    assert_includes menu_item.errors[:page], 'must exist'
  end

  test 'should auto-assign position if not provided' do
    # Clear existing items to avoid uniqueness conflicts
    MenuItem.destroy_all

    page = postables(:about_page) # Use a different page
    menu_item = MenuItem.create!(
      page: page,
      enabled: true
    )
    assert_not_nil menu_item.position
    assert menu_item.position > 0
  end

  test 'should return active menu items in order' do
    # Clear existing items to ensure clean test
    MenuItem.destroy_all

    # Create test items using different pages to avoid uniqueness conflicts
    page1 = postables(:three) # Published Test Page
    page2 = postables(:about_page) # About page
    page3 = postables(:contact_page) # Contact page

    MenuItem.create!(page: page1, position: 1, enabled: true)
    MenuItem.create!(page: page2, position: 2, enabled: true)
    MenuItem.create!(page: page3, position: 3, enabled: false)

    active_items = MenuItem.active_menu_items

    # Only enabled items from published pages should be returned
    assert_equal 2, active_items.length
  end

  test 'should reorder items correctly' do
    # Clear existing items
    MenuItem.destroy_all

    # Create test items using existing pages
    page1 = postables(:three)
    page2 = postables(:about_page)

    item1 = MenuItem.create!(page: page1, position: 1, enabled: true)
    item2 = MenuItem.create!(page: page2, position: 2, enabled: true)

    # Reorder: item2, item1
    new_order = { item2.id.to_s => 1, item1.id.to_s => 2 }
    MenuItem.reorder!(new_order)

    # Reload and check positions
    item1.reload
    item2.reload

    assert_equal 2, item1.position
    assert_equal 1, item2.position
  end

  test 'should invalidate cache when items change' do
    # Mock Rails.cache to verify cache operations
    cache_spy = Minitest::Mock.new
    cache_spy.expect :delete, true, [ MenuItem::CACHE_KEY ]

    Rails.stub :cache, cache_spy do
      MenuItem.invalidate_menu_cache
    end

    cache_spy.verify
  end

  test 'should get label from page title' do
    # Clear existing items to avoid uniqueness conflicts
    MenuItem.destroy_all

    page = postables(:three) # Published Test Page
    menu_item = MenuItem.create!(
      page: page,
      position: 1,
      enabled: true
    )

    assert_equal page.title, menu_item.label
  end

  test 'should get URL from page' do
    # Clear existing items to avoid uniqueness conflicts
    MenuItem.destroy_all

    page = postables(:three) # Published Test Page
    menu_item = MenuItem.create!(
      page: page,
      position: 1,
      enabled: true
    )

    expected_url = "/pages/#{page.slug}"
    assert_equal expected_url, menu_item.url
  end

  test 'should handle page deletion gracefully' do
    # Clear existing items to avoid uniqueness conflicts
    MenuItem.destroy_all

    # Create a new page that we can safely delete
    user = users(:one)
    page = Page.create!(
      title: 'Test Page for Deletion',
      slug: 'test-page-deletion',
      user: user,
      publish: true,
      published_at: Time.current
    )

    MenuItem.create!(
      page: page,
      position: 1,
      enabled: true
    )

    # Delete the page - this should also delete the menu item due to foreign key constraint
    assert_difference 'MenuItem.count', -1 do
      page.destroy!
    end
  end
end
