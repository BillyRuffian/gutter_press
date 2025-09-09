require 'test_helper'

class Manage::GutterPressControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test 'should redirect to sign in when not authenticated' do
    get manage_root_url
    assert_redirected_to new_session_url
  end

  test 'should get index when authenticated' do
    sign_in_as(@user)
    get manage_root_url
    assert_response :success
    assert_select 'h1', 'Dashboard'
  end

  test 'should show dashboard statistics when authenticated' do
    sign_in_as(@user)
    
    # Create some test posts
    Post.create!(title: 'Published Post', user: @user, published_at: 1.hour.ago)
    Post.create!(title: 'Future Post', user: @user, published_at: 1.hour.from_now)
    
    get manage_root_url
    assert_response :success
    
    # Check that statistics are displayed
    assert_select 'strong', text: Post.count.to_s
    assert_select 'strong', text: Post.where('published_at <= ?', Time.current).count.to_s
  end

  test 'should show recent posts when authenticated' do
    sign_in_as(@user)
    
    # Create a recent post
    recent_post = Post.create!(title: 'Recent Post', user: @user, published_at: 1.hour.ago)
    
    get manage_root_url
    assert_response :success
    
    # Check that recent posts are displayed
    assert_select 'a', text: recent_post.title
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end
end
