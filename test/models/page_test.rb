require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test 'page inherits all functionality from postable' do
    user = users(:one)
    page = Page.create!(
      title: 'Test Page',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert page.published?, 'Page should be published when publish=true and published_at is in the past'
    assert Page.published.include?(page), 'Page should be included in published scope'
  end

  test 'page and post scopes work correctly' do
    # We should have both posts and pages in our fixtures
    assert_operator Postable.count, :>, 0
    assert_operator Post.count, :>, 0
    assert_operator Page.count, :>, 0

    # Posts and pages should be separate types
    assert_not_equal Post.all.map(&:class), Page.all.map(&:class)

    # But both should inherit from Postable
    assert Page.new.is_a?(Postable)
    assert Post.new.is_a?(Postable)
  end
end
