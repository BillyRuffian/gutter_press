require 'test_helper'

class DuplicateSlugTest < ActiveSupport::TestCase
  test 'should handle duplicate slug generation for pages' do
    user = users(:one)

    # Create first page
    first_page = Page.create!(
      title: 'Duplicate Slug Test',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'duplicate-slug-test', first_page.slug

    # Create second page with same title
    second_page = Page.create!(
      title: 'Duplicate Slug Test',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'duplicate-slug-test-1', second_page.slug

    # Verify both pages exist
    pages = Page.where(title: 'Duplicate Slug Test')
    assert_equal 2, pages.count
    assert_equal 'duplicate-slug-test', pages.first.slug
    assert_equal 'duplicate-slug-test-1', pages.last.slug
  end
end
