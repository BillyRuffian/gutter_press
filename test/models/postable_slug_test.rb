require 'test_helper'

class PostableSlugTest < ActiveSupport::TestCase
  test 'slug is automatically generated from title' do
    user = users(:one)
    post = Post.create!(
      title: 'This is a Test Post!',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'this-is-a-test-post', post.slug
  end

  test 'slug can be manually set' do
    user = users(:one)
    post = Post.create!(
      title: 'This is a Test Post!',
      slug: 'custom-slug',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'custom-slug', post.slug
  end

  test 'slug is updated when title changes' do
    user = users(:one)
    post = Post.create!(
      title: 'Original Title',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'original-title', post.slug

    post.update!(title: 'Updated Title')
    assert_equal 'updated-title', post.slug
  end

  test 'slug handles duplicates by adding counter' do
    user = users(:one)

    post1 = Post.create!(
      title: 'Duplicate Title',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    post2 = Post.create!(
      title: 'Duplicate Title',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'duplicate-title', post1.slug
    assert_equal 'duplicate-title-1', post2.slug
  end

  test 'to_param returns slug' do
    user = users(:one)
    post = Post.create!(
      title: 'Test Post',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'test-post', post.to_param
  end

  test 'can find post by slug' do
    post = postables(:one)
    found_post = Post.find_by!(slug: post.slug)
    assert_equal post.id, found_post.id
  end

  test 'page slug functionality works too' do
    user = users(:one)
    page = Page.create!(
      title: 'Test Page',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_equal 'test-page', page.slug
    assert_equal 'test-page', page.to_param
  end
end
