require 'test_helper'

class Manage::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @page = Page.create!(
      title: 'Test Page',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
  end

  test 'should redirect to sign in when not authenticated' do
    get manage_pages_url
    assert_redirected_to new_session_url
  end

  test 'should get index when authenticated' do
    sign_in_as(@user)
    get manage_pages_url
    assert_response :success
    assert_select 'h1', 'Pages'
  end

  test 'should show pages table when authenticated' do
    sign_in_as(@user)
    get manage_pages_url
    assert_response :success

    # Check for table headers
    assert_select 'th', text: 'Title'
    assert_select 'th', text: 'Publish'
    assert_select 'th', text: 'Live'
    assert_select 'th', text: 'Actions'
  end

  test 'should show page' do
    sign_in_as(@user)
    get manage_page_url(@page)
    assert_response :success
    assert_select 'h1', @page.title
  end

  test 'should get new' do
    sign_in_as(@user)
    get new_manage_page_url
    assert_response :success
    assert_select 'form'
  end

  test 'should create page with slug' do
    sign_in_as(@user)
    
    assert_difference('Page.count') do
      post manage_pages_url, params: { 
        page: { 
          title: 'New Test Page',
          content: 'New content',
          publish: true,
          published_at: 1.hour.ago
        } 
      }
    end

    page = Page.last
    assert_equal 'new-test-page', page.slug
    assert_redirected_to manage_page_url(page)
  end

  test 'should create page with custom slug' do
    sign_in_as(@user)
    
    assert_difference('Page.count') do
      post manage_pages_url, params: { 
        page: { 
          title: 'New Test Page',
          slug: 'custom-page-slug',
          content: 'New content',
          publish: true,
          published_at: 1.hour.ago
        } 
      }
    end

    page = Page.last
    assert_equal 'custom-page-slug', page.slug
  end

  test 'should get edit' do
    sign_in_as(@user)
    get edit_manage_page_url(@page)
    assert_response :success
    assert_select 'form'
  end

  test 'should update page' do
    sign_in_as(@user)
    patch manage_page_url(@page), params: { 
      page: { 
        title: 'Updated Page Title',
        content: 'Updated content'
      } 
    }
    
    @page.reload
    assert_equal 'Updated Page Title', @page.title
    assert_redirected_to manage_page_url(@page)
  end

  test 'should destroy page' do
    sign_in_as(@user)
    
    assert_difference('Page.count', -1) do
      delete manage_page_url(@page)
    end

    assert_redirected_to manage_pages_url
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end
end
