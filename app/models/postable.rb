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
