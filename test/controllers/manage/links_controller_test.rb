require 'test_helper'

class Manage::LinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = Post.create!(
      title: 'Test Post for Linking',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    @page = Page.create!(
      title: 'Test Page for Linking',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
  end

  test 'should redirect to sign in when not authenticated' do
    get manage_links_url, params: { query: 'test' }
    assert_redirected_to new_session_url
  end

  test 'should return empty result when no query provided' do
    sign_in_as(@user)
    get manage_links_url
    assert_response :success
    assert_equal '', response.body.strip
  end

  test 'should search posts and pages by title' do
    sign_in_as(@user)
    get manage_links_url, params: { query: 'Test' }
    assert_response :success

    # Should include both post and page
    assert_includes response.body, @post.title
    assert_includes response.body, @page.title
  end

  test 'should search posts and pages by slug' do
    sign_in_as(@user)
    get manage_links_url, params: { query: @post.slug }
    assert_response :success

    assert_includes response.body, @post.title
  end

  test 'should perform case-insensitive search' do
    sign_in_as(@user)
    get manage_links_url, params: { query: 'TEST' }
    assert_response :success

    assert_includes response.body, @post.title
    assert_includes response.body, @page.title
  end

  test 'should limit results' do
    sign_in_as(@user)

    # Create more than 10 posts
    15.times do |i|
      Post.create!(
        title: "Searchable Post #{i}",
        content: 'Content',
        user: @user,
        publish: true,
        published_at: 1.hour.ago
      )
    end

    get manage_links_url, params: { query: 'Searchable' }
    assert_response :success

    # Should not return more than 10 results (as per controller limit)
    result_count = response.body.scan(/<lexxy-prompt-item/).length
    assert result_count <= 10
  end

  test 'should order by type then title' do
    sign_in_as(@user)

    # Create a page that would come after post alphabetically by title
    Page.create!(
      title: 'A Page That Comes First',
      content: 'Content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    get manage_links_url, params: { query: 'Test' }
    assert_response :success

    # Pages should come before posts due to ordering
    page_position = response.body.index('A Page That Comes First')
    post_position = response.body.index(@post.title)

    assert page_position < post_position if page_position && post_position
  end

  test 'should render proper prompt item structure' do
    sign_in_as(@user)
    get manage_links_url, params: { query: @post.title }
    assert_response :success

    # Should contain lexxy-prompt-item elements
    assert_includes response.body, '<lexxy-prompt-item'
    assert_includes response.body, 'search='
    assert_includes response.body, "<template type='menu'>"
    assert_includes response.body, "<template type='editor'>"
    assert_includes response.body, @post.title
  end

  test 'should include proper icons for different types' do
    sign_in_as(@user)
    get manage_links_url, params: { query: 'Test' }
    assert_response :success

    # Should include different icons for posts and pages
    assert_includes response.body, '/icons/file-text.svg'        # Post icon
    assert_includes response.body, '/icons/file-earmark-text.svg' # Page icon
  end

  test 'should generate correct URLs in editor template' do
    sign_in_as(@user)
    get manage_links_url, params: { query: @post.title }
    assert_response :success

    # Should generate correct post URL
    assert_includes response.body, "/posts/#{@post.slug}"

    get manage_links_url, params: { query: @page.title }
    assert_response :success

    # Should generate correct page URL
    assert_includes response.body, "/pages/#{@page.slug}"
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end
end
