require 'application_system_test_case'

class PagesTest < ApplicationSystemTestCase
  setup do
    @page = Page.create!(
      title: 'Test Page',
      content: 'Test page content',
      user: users(:one),
      publish: true,
      published_at: 1.hour.ago
    )
    @user = users(:one)
  end

  test 'visiting the pages show' do
    visit page_url(@page)
    assert_selector 'h1', text: @page.title
    assert_selector '.page-content'
  end

  test 'should manage pages when authenticated' do
    sign_in_as(@user)

    # Visit manage pages
    visit manage_pages_url
    assert_selector 'h1', text: 'Pages'
    assert_selector 'table'

    # Check that pages are listed
    assert_selector 'td', text: @page.title
  end

  test 'should create new page through management interface' do
    sign_in_as(@user)

    visit manage_pages_url
    click_link 'New Page'

    assert_selector 'h1', text: 'New Page'

    # Fill in page form
    fill_in 'Title', with: 'System Test Page'

    # Skip rich text editor content for now - focus on slug functionality
    # The content field will be empty but that's OK for testing slug generation

    # Fill in custom slug in sidebar
    fill_in 'URL Slug', with: 'custom-test-slug'

    # Publish the page
    check 'Ready to publish'

    # Submit form
    click_button 'Create Page'

    # Should redirect to show page
    assert_selector 'h1', text: 'System Test Page'

    # Verify page was created with correct slug
    created_page = Page.find_by(title: 'System Test Page')
    assert_not_nil created_page
    assert_equal 'custom-test-slug', created_page.slug

    # Verify we can access the page via slug URL
    visit page_url(created_page)
    assert_selector 'h1', text: 'System Test Page'
  end

  test 'should edit existing page' do
    sign_in_as(@user)

    visit manage_page_url(@page)
    click_link 'Edit'

    assert_selector 'h1', text: 'Edit Page'

    # Update title
    fill_in 'Title', with: 'Updated Page Title'

    # Update slug
    fill_in 'URL Slug', with: 'updated-slug'

    click_button 'Update Page'

    # Should show updated page
    assert_selector 'h1', text: 'Updated Page Title'

    # Verify changes were saved
    @page.reload
    assert_equal 'Updated Page Title', @page.title
    assert_equal 'updated-slug', @page.slug
  end

  test 'should auto-generate slug from title when not specified' do
    sign_in_as(@user)

    visit new_manage_page_url

    fill_in 'Title', with: 'Auto Generated Slug Page!'

    # Skip rich text editor content for slug testing

    check 'Ready to publish'

    # Leave slug field empty to test auto-generation

    click_button 'Create Page'

    # Should create page with auto-generated slug
    created_page = Page.find_by(title: 'Auto Generated Slug Page!')
    assert_not_nil created_page
    assert_equal 'auto-generated-slug-page', created_page.slug
  end

  test 'should handle duplicate slugs by adding counter' do
    sign_in_as(@user)

    # Create first page
    visit new_manage_page_url
    fill_in 'Title', with: 'Duplicate Slug Test'

    # Skip rich text editor content for slug testing

    check 'Ready to publish'
    click_button 'Create Page'

    first_page = Page.find_by(title: 'Duplicate Slug Test')
    assert_equal 'duplicate-slug-test', first_page.slug

    # Create second page with same title
    visit new_manage_page_url
    fill_in 'Title', with: 'Duplicate Slug Test'

    # Skip rich text editor content for slug testing

    check 'Ready to publish'
    click_button 'Create Page'

    second_page = Page.where(title: 'Duplicate Slug Test').last
    assert_equal 'duplicate-slug-test-1', second_page.slug
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
end
