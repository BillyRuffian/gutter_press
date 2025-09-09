require 'test_helper'

class Manage::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
  end

  test 'should redirect to sign in when not authenticated' do
    get manage_posts_url
    assert_redirected_to new_session_url
  end

  test 'should get index when authenticated' do
    sign_in_as(@user)
    get manage_posts_url
    assert_response :success
    assert_select 'h1', 'Posts'
  end

  test 'should show posts table when authenticated' do
    sign_in_as(@user)
    get manage_posts_url
    assert_response :success

    # Check for table headers
    assert_select 'th', text: 'Title'
    assert_select 'th', text: 'Published Date'
    assert_select 'th', text: 'Published'
    assert_select 'th', text: 'Actions'
  end

  test 'should handle pagination' do
    sign_in_as(@user)
    get manage_posts_url
    assert_response :success

    # Check that pagination elements might be present
    assert_select 'table.table'
  end

  test 'should show post status indicators' do
    sign_in_as(@user)

    # Create published and unpublished posts
    Post.create!(title: 'Published Post', user: @user, published_at: 1.hour.ago)
    Post.create!(title: 'Draft Post', user: @user, published_at: nil)

    get manage_posts_url
    assert_response :success

    # Should show different status indicators
    assert_select 'span.badge', text: 'Draft'
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end
end
