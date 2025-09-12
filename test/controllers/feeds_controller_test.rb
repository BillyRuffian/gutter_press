require 'test_helper'

class FeedsControllerTest < ActionDispatch::IntegrationTest
  test 'should get atom feed as xml' do
    get feed_path
    assert_response :success
    assert_equal 'application/xml; charset=utf-8', response.content_type
  end

  test 'atom feed should contain valid xml structure' do
    get feed_path
    assert_response :success

    # Parse XML to verify structure
    doc = Nokogiri::XML(response.body)
    assert_equal 'feed', doc.root.name
    assert_equal 'http://www.w3.org/2005/Atom', doc.root.namespace.href

    # Verify required Atom elements
    assert doc.at_xpath('//atom:title', 'atom' => 'http://www.w3.org/2005/Atom')
    assert doc.at_xpath("//atom:link[@rel='self']", 'atom' => 'http://www.w3.org/2005/Atom')
    assert doc.at_xpath('//atom:link[not(@rel)]', 'atom' => 'http://www.w3.org/2005/Atom')
    assert doc.at_xpath('//atom:updated', 'atom' => 'http://www.w3.org/2005/Atom')
    assert doc.at_xpath('//atom:id', 'atom' => 'http://www.w3.org/2005/Atom')
    assert doc.at_xpath('//atom:author', 'atom' => 'http://www.w3.org/2005/Atom')
  end

  test 'atom feed should include published posts only' do
    user = users(:one)

    # Create published post
    Post.create!(
      title: 'Published Post',
      content: 'This is published',
      user: user,
      published_at: 1.day.ago
    )

    # Create unpublished post
    Post.create!(
      title: 'Unpublished Post',
      content: 'This is not published',
      user: user,
      published_at: nil
    )

    get feed_path
    assert_response :success

    # Parse XML
    doc = Nokogiri::XML(response.body)
    entries = doc.xpath('//atom:entry', 'atom' => 'http://www.w3.org/2005/Atom')

    # Should only include published posts
    entry_titles = entries.xpath('.//atom:title', 'atom' => 'http://www.w3.org/2005/Atom').map(&:text)
    assert_includes entry_titles, 'Published Post'
    assert_not_includes entry_titles, 'Unpublished Post'
  end

  test 'atom feed entries should have required elements' do
    user = users(:one)
    Post.create!(
      title: 'Test Post',
      content: 'Test content with <strong>HTML</strong>',
      user: user,
      published_at: 1.day.ago
    )

    get feed_path
    assert_response :success

    doc = Nokogiri::XML(response.body)
    entry = doc.at_xpath("//atom:entry[atom:title='Test Post']", 'atom' => 'http://www.w3.org/2005/Atom')
    assert entry, 'Should find entry for test post'

    # Verify required entry elements
    assert entry.at_xpath('.//atom:title', 'atom' => 'http://www.w3.org/2005/Atom')
    assert entry.at_xpath('.//atom:link', 'atom' => 'http://www.w3.org/2005/Atom')
    assert entry.at_xpath('.//atom:updated', 'atom' => 'http://www.w3.org/2005/Atom')
    assert entry.at_xpath('.//atom:id', 'atom' => 'http://www.w3.org/2005/Atom')
    assert entry.at_xpath('.//atom:content', 'atom' => 'http://www.w3.org/2005/Atom')
    assert entry.at_xpath('.//atom:author', 'atom' => 'http://www.w3.org/2005/Atom')
    assert entry.at_xpath('.//atom:published', 'atom' => 'http://www.w3.org/2005/Atom')
  end

  test 'atom feed should limit to 20 posts' do
    user = users(:one)

    # Create 25 published posts
    25.times do |i|
      Post.create!(
        title: "Post #{i + 1}",
        content: "Content #{i + 1}",
        user: user,
        published_at: (i + 1).days.ago
      )
    end

    get feed_path
    assert_response :success

    doc = Nokogiri::XML(response.body)
    entries = doc.xpath('//atom:entry', 'atom' => 'http://www.w3.org/2005/Atom')

    # Should be limited to 20 entries
    assert_equal 20, entries.length
  end

  test 'atom feed should be accessible without authentication' do
    # Clear any session data
    get feed_path
    assert_response :success
    assert_match(/^<\?xml/, response.body)
  end
end
