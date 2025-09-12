class Post < ApplicationRecord
  belongs_to :user
  has_rich_text :content

  validates :title, presence: true

  scope :published, -> { where('published_at IS NOT NULL AND published_at <= ?', Time.current) }

  def published?
    published_at.present? && published_at <= Time.current
  end
end
