class Post < Postable
  belongs_to :user

  validates :title, presence: true
  validates :user, presence: true

  has_rich_text :content

  scope :published, -> { where(publish: true).where('published_at IS NOT NULL AND published_at <= ?', Time.current) }

  def published?
    publish == true && published_at.present? && published_at <= Time.current
  end
end
