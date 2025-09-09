require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'should be valid with title, user, and published_at' do
    post = Post.new(
      title: 'Test Post',
      user: users(:one),
      published_at: 1.hour.ago
    )
    assert post.valid?
  end

  test 'should require title' do
    post = Post.new(user: users(:one), published_at: 1.hour.ago)
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test 'should require user' do
    post = Post.new(title: 'Test Post', published_at: 1.hour.ago)
    assert_not post.valid?
  end

  test 'published? returns true when published_at is in the past' do
    post = posts(:one)
    post.published_at = 1.hour.ago
    assert post.published?
  end

  test 'published? returns false when published_at is in the future' do
    post = posts(:one)
    post.published_at = 1.hour.from_now
    assert_not post.published?
  end

  test 'published? returns false when published_at is nil' do
    post = posts(:one)
    post.published_at = nil
    assert_not post.published?
  end

  test 'should have rich text content' do
    post = posts(:one)
    assert_respond_to post, :content
    assert_respond_to post, :content=
  end
end
