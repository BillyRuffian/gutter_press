require 'test_helper'

class PagesCoverImageControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @page = Page.create!(
      title: 'Test Page',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    sign_in_as @user
  end

  test 'can create page with cover image' do
    image_file = fixture_file_upload('test.jpg', 'image/jpeg')

    assert_difference('Page.count') do
      post manage_pages_url, params: {
        page: {
          title: 'New Page with Image',
          content: 'Content here',
          cover_image: image_file,
          cover_image_attribution: 'Photo by Test User',
          publish: true,
          published_at: 1.hour.ago
        }
      }
    end

    new_page = Page.last
    assert new_page.has_cover_image?
    assert_equal 'Photo by Test User', new_page.cover_image_attribution
  end

  test 'can update page with cover image' do
    image_file = fixture_file_upload('test.jpg', 'image/jpeg')

    patch manage_page_url(@page), params: {
      page: {
        cover_image: image_file,
        cover_image_attribution: 'Updated attribution'
      }
    }

    @page.reload
    assert @page.has_cover_image?
    assert_equal 'Updated attribution', @page.cover_image_attribution
  end

  test 'can remove cover image' do
    # First add an image
    @page.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )
    assert @page.has_cover_image?

    # Then remove it
    patch manage_page_url(@page), params: {
      page: {
        remove_cover_image: '1'
      }
    }

    @page.reload
    assert_not @page.has_cover_image?
  end

  test 'validates cover image format on upload' do
    invalid_file = fixture_file_upload('test.txt', 'text/plain')

    patch manage_page_url(@page), params: {
      page: {
        cover_image: invalid_file
      }
    }

    assert_response :unprocessable_entity
    @page.reload
    assert_not @page.has_cover_image?
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end
end
