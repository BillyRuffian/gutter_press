require 'application_system_test_case'

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
    @user = users(:one)
    # Ensure the post is published for system tests
    @post.update!(published_at: 1.hour.ago)
  end

  private

  def sign_in_as(user)
    visit new_session_url
    fill_in 'Email Address', with: user.email_address
    fill_in 'Password', with: 'password'
    click_button 'Sign In'
    # Wait for redirect to complete
    assert_selector 'h1', text: 'Latest Posts'
  end

  test 'visiting the index' do
    visit posts_url
    assert_selector 'h1', text: 'Latest Posts'
    assert_selector 'article', minimum: 1
  end

  test 'should show individual post' do
    visit post_url(@post)
    assert_selector 'h1', text: @post.title
    assert_selector '.post-content'
    assert_selector '.post-meta'
  end

  test 'should sign in and access manage interface' do
    sign_in_as(@user)

    # Now navigate to manage interface
    visit manage_root_url
    assert_selector 'h1', text: 'Dashboard'
    assert_selector '.card', minimum: 1
  end

  test 'should manage posts when authenticated' do
    sign_in_as(@user)

    # Visit manage posts
    visit manage_posts_url
    assert_selector 'h1', text: 'Posts'
    assert_selector 'table'

    # Check that posts are listed
    assert_selector 'td', text: @post.title
  end
end
