class Page < Postable
  has_many :menu_items, dependent: :destroy
end
