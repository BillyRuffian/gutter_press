class SiteSetting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  # Value can be empty string for optional settings

  # Add hero image attachment (we'll use a singleton pattern since we only need one)
  has_one_attached :hero_image

  # Cache key for storing all settings in Rails.cache
  CACHE_KEY = 'site_settings_all'.freeze

  # Default settings - these are used as fallbacks when no database record exists
  DEFAULTS = {
    'site_name' => 'Gutter Press',
    'site_description' => 'A modern blogging platform',
    'site_tagline' => 'Share your stories with the world',
    'posts_per_page' => '10',
    'allow_comments' => 'true',
    'contact_email' => '',
    'footer_text' => '© 2025 Gutter Press. All rights reserved.',
    'social_twitter' => '',
    'social_github' => '',
    'social_linkedin' => '',
    'analytics_code' => '',
    'hero_enabled' => 'false',
    'hero_title' => 'Welcome to Our Blog',
    'hero_subtitle' => 'Discover amazing stories and insights'
  }.freeze

  # Class method to get a setting value with caching
  def self.get(key)
    # First try to get from cache
    all_settings = Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
      # Cache miss - load all settings from database
      pluck(:key, :value).to_h
    end

    # Return cached value or fall back to default
    all_settings[key.to_s] || DEFAULTS[key.to_s]
  end

  # Class method to set a setting value and invalidate cache
  def self.set(key, value)
    setting = find_or_initialize_by(key: key.to_s)
    setting.value = value.to_s

    if setting.save
      # Invalidate the cache so next request will reload from database
      Rails.cache.delete(CACHE_KEY)
      value
    else
      false
    end
  end

  # Bulk update method for updating multiple settings at once
  def self.update_multiple(settings_hash)
    transaction do
      settings_hash.each do |key, value|
        setting = find_or_initialize_by(key: key.to_s)
        setting.value = value.to_s
        setting.save!
      end

      # Invalidate cache once after all updates
      Rails.cache.delete(CACHE_KEY)
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  # Get all settings as a hash (useful for forms)
  def self.all_as_hash
    Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) do
      pluck(:key, :value).to_h
    end.reverse_merge(DEFAULTS)
  end

  # Boolean helper methods for common settings
  def self.allow_comments?
    get('allow_comments') == 'true'
  end

  # Integer helper for posts per page
  def self.posts_per_page
    get('posts_per_page').to_i
  end

  # Commonly used settings as direct methods
  def self.site_name
    get('site_name')
  end

  def self.site_description
    get('site_description')
  end

  def self.site_tagline
    get('site_tagline')
  end

  def self.footer_text
    get('footer_text')
  end

  # Hero section settings
  def self.hero_enabled?
    get('hero_enabled') == 'true'
  end

  def self.hero_title
    get('hero_title')
  end

  def self.hero_subtitle
    get('hero_subtitle')
  end

  # Hero image attachment methods (using singleton pattern)
  def self.hero_image_record
    @hero_image_record ||= find_or_create_by(key: '_hero_image_record') do |record|
      record.value = 'singleton'
    end
  end

  def self.hero_image
    hero_image_record.hero_image
  end

  def self.has_hero_image?
    hero_image.attached?
  end

  def self.hero_image_attribution
    hero_image_record.hero_image_attribution
  end

  def self.set_hero_image_attribution(attribution)
    hero_image_record.update(hero_image_attribution: attribution)
    clear_cache
  end

  # Hero image helper methods (similar to postables)
  def self.hero_image_hero
    return unless has_hero_image?
    hero_image.variant(resize_to_limit: [ 1920, 1080 ])
  end

  # Clear cache after any database changes
  after_save :clear_cache
  after_destroy :clear_cache

  # Class method to clear cache
  def self.clear_cache
    Rails.cache.delete(CACHE_KEY)
  end

  private

  def clear_cache
    self.class.clear_cache
  end
end
