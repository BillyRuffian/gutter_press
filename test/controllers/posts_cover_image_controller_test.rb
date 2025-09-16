require 'test_helper'

class PostsCoverImageControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = Post.create!(
      title: 'Test Post',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
    sign_in_as @user
  end

  test 'can create post with cover image' do
    image_file = fixture_file_upload('test.jpg', 'image/jpeg')

    assert_difference('Post.count') do
      post manage_posts_url, params: {
        post: {
          title: 'New Post with Image',
          content: 'Content here',
          cover_image: image_file,
          cover_image_attribution: 'Photo by Test User',
          publish: true,
          published_at: 1.hour.ago
        }
      }
    end

    new_post = Post.last
    assert new_post.has_cover_image?
    assert_equal 'Photo by Test User', new_post.cover_image_attribution
  end

  test 'can update post with cover image' do
    image_file = fixture_file_upload('test.jpg', 'image/jpeg')

    patch manage_post_url(@post), params: {
      post: {
        cover_image: image_file,
        cover_image_attribution: 'Updated attribution'
      }
    }

    @post.reload
    assert @post.has_cover_image?
    assert_equal 'Updated attribution', @post.cover_image_attribution
  end

  test 'can remove cover image' do
    # First add an image
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )
    assert @post.has_cover_image?

    # Then remove it
    patch manage_post_url(@post), params: {
      post: {
        remove_cover_image: '1'
      }
    }

    @post.reload
    assert_not @post.has_cover_image?
  end

  test 'validates cover image format on upload' do
    invalid_file = fixture_file_upload('test.txt', 'text/plain')

    patch manage_post_url(@post), params: {
      post: {
        cover_image: invalid_file
      }
    }

    assert_response :unprocessable_entity
    @post.reload
    assert_not @post.has_cover_image?
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end
end
