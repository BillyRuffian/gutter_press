class Post < ApplicationRecord
  belongs_to :user
  has_rich_text :content

  def published?
    published_at.present? && published_at <= Time.current
  end
end
