require 'test_helper'

class PostableTest < ActiveSupport::TestCase
  test 'post is published when publish is true and published_at is in the past' do
    user = users(:one)
    post = Post.create!(
      title: 'Test Post',
      user: user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert post.published?, 'Post should be published when publish=true and published_at is in the past'
    assert Post.published.include?(post), 'Post should be included in published scope'
  end

  test 'post is not published when publish is false even with past published_at' do
    user = users(:one)
    post = Post.create!(
      title: 'Test Post',
      user: user,
      publish: false,
      published_at: 1.hour.ago
    )

    assert_not post.published?, 'Post should not be published when publish=false'
    assert_not Post.published.include?(post), 'Post should not be included in published scope'
  end

  test 'post is not published when publish is true but published_at is in the future' do
    user = users(:one)
    post = Post.create!(
      title: 'Test Post',
      user: user,
      publish: true,
      published_at: 1.hour.from_now
    )

    assert_not post.published?, 'Post should not be published when published_at is in the future'
    assert_not Post.published.include?(post), 'Post should not be included in published scope'
  end

  test 'post is not published when publish is true but published_at is nil' do
    user = users(:one)
    post = Post.create!(
      title: 'Test Post',
      user: user,
      publish: true,
      published_at: nil
    )

    assert_not post.published?, 'Post should not be published when published_at is nil'
    assert_not Post.published.include?(post), 'Post should not be included in published scope'
  end

  test 'post is not published when both publish is false and published_at is nil' do
    user = users(:one)
    post = Post.create!(
      title: 'Test Post',
      user: user,
      publish: false,
      published_at: nil
    )

    assert_not post.published?, 'Post should not be published when both conditions are false'
    assert_not Post.published.include?(post), 'Post should not be included in published scope'
  end
end
