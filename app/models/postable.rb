class Postable < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :user, presence: true
  validates :slug, presence: true, uniqueness: true

  has_rich_text :content

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

  private

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
end
