require 'test_helper'

class PostableCoverImageTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @post = Post.create!(
      title: 'Test Post',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )
  end

  test 'has_cover_image? returns false when no image attached' do
    assert_not @post.has_cover_image?
  end

  test 'has_cover_image? returns true when image is attached' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )
    assert @post.has_cover_image?
  end

  test 'cover_image_thumbnail returns nil without image' do
    assert_nil @post.cover_image_thumbnail
  end

  test 'cover_image_hero returns nil without image' do
    assert_nil @post.cover_image_hero
  end

  test 'cover_image_thumbnail returns variant with image' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )

    # Mock the variant_processed? method to return true
    @post.define_singleton_method(:variant_processed?) { |_| true }

    assert_not_nil @post.cover_image_thumbnail
  end

  test 'cover_image_hero returns variant with image' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )

    # Mock the variant_processed? method to return true
    @post.define_singleton_method(:variant_processed?) { |_| true }

    assert_not_nil @post.cover_image_hero
  end

  test 'validates cover image format - accepts JPEG' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )
    assert @post.valid?
  end

  test 'validates cover image format - accepts PNG' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.png',
      content_type: 'image/png'
    )
    assert @post.valid?
  end

  test 'validates cover image format - accepts WebP' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.webp',
      content_type: 'image/webp'
    )
    assert @post.valid?
  end

  test 'validates cover image format - rejects unsupported format' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.gif',
      content_type: 'image/gif'
    )
    assert_not @post.valid?
    assert_includes @post.errors[:cover_image], 'must be a JPEG, PNG, or WebP image'
  end

  test 'validates cover image size - accepts normal files' do
    # Test that normal sized files are accepted
    assert @post.valid? # Post without image should be valid

    # Attach a regular sized image - should be valid
    @post.cover_image.attach(
      io: StringIO.new('normal size content'),
      filename: 'normal.jpg',
      content_type: 'image/jpeg'
    )

    assert @post.valid?
  end

  test 'cover_image_attribution can be set and retrieved' do
    attribution = 'Photo by John Doe'
    @post.cover_image_attribution = attribution
    @post.save!

    assert_equal attribution, @post.reload.cover_image_attribution
  end

  test 'cover_image_attribution is optional' do
    @post.cover_image_attribution = nil
    assert @post.valid?
  end

  test 'works with Page model too' do
    page = Page.create!(
      title: 'Test Page',
      content: 'Test content',
      user: @user,
      publish: true,
      published_at: 1.hour.ago
    )

    assert_not page.has_cover_image?

    page.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )

    assert page.has_cover_image?

    # Mock the variant_processed? method to return true
    page.define_singleton_method(:variant_processed?) { |_| true }

    assert_not_nil page.cover_image_thumbnail
    assert_not_nil page.cover_image_hero
  end

  test 'cover_image_thumbnail returns nil when variants not processed yet' do
    @post.cover_image.attach(
      io: StringIO.new('fake image'),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    )

    # Before processing, should return nil to prevent signed_id errors
    assert_nil @post.cover_image_thumbnail
    assert_nil @post.cover_image_hero
  end
end
