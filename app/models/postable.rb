class Postable < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :user, presence: true
  validates :slug, presence: true, uniqueness: true

  has_rich_text :content
  has_one_attached :cover_image

  validate :cover_image_format, if: -> { cover_image.attached? }

  # Trigger variant processing when cover image changes
  after_commit :process_cover_image_variants_async, if: :cover_image_just_attached?

  scope :published, -> { where(publish: true).where('published_at IS NOT NULL AND published_at <= ?', Time.current) }

  before_validation :generate_slug, if: -> { title.present? && slug.blank? }
  before_validation :regenerate_slug_if_title_changed, if: -> { title.present? && title_changed? && !slug_changed? }

  def published?
    publish == true && published_at.present? && published_at <= Time.current
  end

  def to_param
    slug
  end

  def display_excerpt
    return excerpt if excerpt.present?

    # Extract first paragraph from content
    return '' unless content.present?

    # Get the plain text version of the rich text content
    plain_content = content.to_plain_text.strip
    return '' if plain_content.blank?

    # Handle both literal \n and actual newlines for paragraph splitting
    # First, try splitting on actual double newlines
    paragraphs = plain_content.split(/\n\s*\n/).map(&:strip).reject(&:blank?)

    # If that didn't work, try splitting on literal \n\n (escaped backslashes)
    if paragraphs.length == 1
      paragraphs = plain_content.split('\\n\\n').map(&:strip).reject(&:blank?)
    end

    if paragraphs.length > 1
      first_paragraph = paragraphs.first
      # Clean up any remaining newlines (both literal and actual) within the paragraph
      first_paragraph = first_paragraph.gsub(/\\n|\n/, ' ').strip

      # If first paragraph is too short (less than 20 characters), include more content
      if first_paragraph.length < 20
        # Take first 200 characters as fallback
        plain_content.gsub(/\\n|\n/, ' ').truncate(200)
      else
        # Return the first paragraph, truncated if necessary
        first_paragraph.truncate(300)
      end
    else
      # If we couldn't split paragraphs, truncate the full content
      plain_content.gsub(/\\n|\n/, ' ').truncate(200)
    end
  end

  # Cover image helper methods
  def has_cover_image?
    cover_image.attached?
  end

  def cover_image_variants_ready?
    return false unless has_cover_image?

    thumbnail_ready = variant_processed?(cover_image.variant(resize_to_fill: [ 300, 200 ]))
    hero_ready = variant_processed?(cover_image.variant(resize_to_limit: [ 1920, 1080 ]))

    thumbnail_ready && hero_ready
  end

  def cover_image_thumbnail
    return unless has_cover_image?

    # Try to get existing processed variant first
    thumbnail_variant = cover_image.variant(resize_to_fill: [ 300, 200 ])

    # Check if variant is already processed
    return thumbnail_variant if variant_processed?(thumbnail_variant)

    # Enqueue background job to process variants if not already processing
    ensure_variants_processing

    # Return the variant (will be processed on first access if not done in background)
    thumbnail_variant
  end

  def cover_image_hero
    return unless has_cover_image?

    # Try to get existing processed variant first
    hero_variant = cover_image.variant(resize_to_limit: [ 1920, 1080 ])

    # Check if variant is already processed
    return hero_variant if variant_processed?(hero_variant)

    # Enqueue background job to process variants if not already processing
    ensure_variants_processing

    # Return the variant (will be processed on first access if not done in background)
    hero_variant
  end

  private

  def variant_processed?(variant)
    # Check if the variant record exists in the database
    variant_record = ActiveStorage::VariantRecord.find_by(
      blob: cover_image.blob,
      variation_digest: variant.variation.digest
    )

    variant_record&.image&.attached?
  end

  def ensure_variants_processing
    # Use a cache key to prevent multiple job enqueues for the same attachment
    cache_key = "processing_variants_#{cover_image.blob.key}"

    # Only enqueue if not already processing (cache expires after 5 minutes)
    unless Rails.cache.exist?(cache_key)
      Rails.cache.write(cache_key, true, expires_in: 5.minutes)
      ProcessCoverImageVariantsJob.perform_later(self)
      Rails.logger.info "Enqueued ProcessCoverImageVariantsJob for #{self.class.name}##{id}"
    end
  end

  def cover_image_just_attached?
    return false unless cover_image.attached?

    # Check if this is a new attachment (created in the last few seconds)
    cover_image.attachment.created_at > 10.seconds.ago
  end

  def process_cover_image_variants_async
    return unless cover_image.attached?

    ProcessCoverImageVariantsJob.perform_later(self)
    Rails.logger.info "Scheduled ProcessCoverImageVariantsJob for #{self.class.name}##{id}"
  end

  def generate_slug
    base_slug = title.parameterize
    candidate_slug = base_slug
    counter = 1

    while self.class.where(slug: candidate_slug).where.not(id: id).exists?
      candidate_slug = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate_slug
  end

  def regenerate_slug_if_title_changed
    generate_slug
  end

  def cover_image_format
    return unless cover_image.attached?

    unless cover_image.content_type.in?([ 'image/jpeg', 'image/png', 'image/webp' ])
      errors.add(:cover_image, 'must be a JPEG, PNG, or WebP image')
    end

    if cover_image.byte_size > 10.megabytes
      errors.add(:cover_image, 'must be smaller than 10MB')
    end
  end
end
