class Post < ApplicationRecord
  belongs_to :user
  has_rich_text :content

  validates :title, presence: true

  def published?
    published_at.present? && published_at <= Time.current
  end
end
