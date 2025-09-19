class MenuItem < ApplicationRecord
  belongs_to :page, class_name: 'Page'

  validates :position, presence: true, uniqueness: true
  validates :page_id, presence: true, uniqueness: true

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(:position) }

  # Cache key for menu items
  CACHE_KEY = 'menu_items_cache'.freeze

  # Cache expiration time
  CACHE_EXPIRATION = 1.hour

  # Callbacks to invalidate cache when menu items change
  after_save :invalidate_cache
  after_destroy :invalidate_cache

  # Get all active menu items with their pages, cached
  def self.active_menu_items
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRATION) do
      includes(:page)
        .joins(:page)
        .merge(Page.published)
        .where(enabled: true)
        .ordered
        .map do |item|
          {
            id: item.id,
            name: item.page.title,
            path: "/pages/#{item.page.slug}",
            page_id: item.page.id,
            position: item.position
          }
        end
    end
  end

  # Get all menu items for admin management (not cached as it's admin-only)
  def self.for_admin
    includes(:page).ordered
  end

  # Bulk reorder menu items
  def self.reorder!(item_positions)
    transaction do
      # First, set all positions to negative values to avoid unique constraint conflicts
      max_position = maximum(:position) || 0
      offset = max_position + 1000

      item_positions.each do |item_id, new_position|
        where(id: item_id).update_all(position: -(new_position + offset))
      end

      # Then update to the actual positive positions
      item_positions.each do |item_id, new_position|
        where(id: item_id).update_all(position: new_position)
      end

      invalidate_menu_cache
    end
  end

  # Class method to invalidate cache
  def self.invalidate_menu_cache
    Rails.cache.delete(CACHE_KEY)
  end

  # Get next available position
  def self.next_position
    (maximum(:position) || 0) + 1
  end

  private

  def invalidate_cache
    self.class.invalidate_menu_cache
  end
end
