require 'test_helper'

class PostableExcerptTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test 'display_excerpt returns excerpt when present' do
    post = Post.create!(
      title: 'Test Post',
      excerpt: 'This is a custom excerpt',
      content: 'This is the full content with much more detail.',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'This is a custom excerpt', post.display_excerpt
  end

  test 'display_excerpt returns first paragraph when excerpt is blank' do
    post = Post.create!(
      title: 'Test Post',
      content: 'This is the first paragraph.\n\nThis is the second paragraph with more content.',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'This is the first paragraph.', post.display_excerpt
  end

  test 'display_excerpt truncates long first paragraph' do
    long_paragraph = 'A' * 400
    post = Post.create!(
      title: 'Test Post',
      content: "#{long_paragraph}\n\nSecond paragraph.",
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    result = post.display_excerpt
    assert result.length <= 303 # 300 + "..."
    assert result.ends_with?('...')
  end

  test 'display_excerpt returns fallback when first paragraph is too short' do
    post = Post.create!(
      title: 'Test Post',
      content: 'Short.\n\nThis is a much longer second paragraph with more content that should be included in the excerpt.',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    result = post.display_excerpt
    assert result.length <= 203 # 200 + "..."
    assert result.include?('Short.')
    assert result.include?('This is a much longer')
  end

  test 'display_excerpt returns empty string when content is blank' do
    post = Post.create!(
      title: 'Test Post',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal '', post.display_excerpt
  end

  test 'display_excerpt handles empty excerpt' do
    post = Post.create!(
      title: 'Test Post',
      excerpt: '',
      content: 'This is the content that should be used.',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'This is the content that should be used.', post.display_excerpt
  end

  test 'display_excerpt works for pages too' do
    page = Page.create!(
      title: 'Test Page',
      excerpt: 'This is a page excerpt',
      content: 'This is the page content.',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'This is a page excerpt', page.display_excerpt
  end
end
