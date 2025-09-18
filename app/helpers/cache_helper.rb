module CacheHelper
  # Generate cache keys for different content types
  def cache_key_for_post(post)
    "post/#{post.slug}/v#{post.updated_at.to_i}/#{site_settings_cache_key}"
  end

  def cache_key_for_page(page)
    "page/#{page.slug}/v#{page.updated_at.to_i}/#{site_settings_cache_key}"
  end

  def cache_key_for_posts_index(posts_scope, pagy)
    # Include the latest post update time and pagination in cache key
    latest_update = posts_scope.maximum(:updated_at)&.to_i || 0
    page_info = "page_#{pagy.page}_per_#{pagy.limit}"
    "posts_index/#{latest_update}/#{page_info}/#{site_settings_cache_key}"
  end

  def cache_key_for_hero_section(item)
    "hero/#{item.class.name.downcase}/#{item.slug}/v#{item.updated_at.to_i}"
  end

  # Cached page title computation
  def cached_page_title(item = nil)
    case
    when item.respond_to?(:title)
      "#{item.title} - #{site_name}"
    when controller_name == 'posts' && action_name == 'index'
      "#{site_name} - #{site_description}"
    else
      site_name
    end
  end

  # Cached meta description computation
  def cached_meta_description(item = nil)
    case
    when item.respond_to?(:excerpt) && item.excerpt.present?
      truncate(strip_tags(item.excerpt), length: 160)
    when item.respond_to?(:content)
      truncate(strip_tags(item.content.to_s), length: 160)
    else
      site_description
    end
  end

  # Cached meta image computation
  def cached_meta_image(item = nil)
    if item&.respond_to?(:has_cover_image?) && item.has_cover_image?
      # Use the cover image URL if available
      item.cover_image.attached? ? url_for(item.cover_image) : nil
    else
      # Fall back to site default or nil
      nil
    end
  end

  # Cache key for hero sections
  def cached_hero_section(item)
    return nil unless item&.respond_to?(:has_cover_image?) && item.has_cover_image?

    Rails.cache.fetch(cache_key_for_hero_section(item), expires_in: 1.hour) do
      {
        has_hero: true,
        image_url: item.cover_image_hero,
        title: item.title,
        published_at: item.published_at,
        user_email: item.user.email_address,
        attribution: item.cover_image_attribution
      }
    end
  end

  private

  # Include site settings in cache keys to invalidate when settings change
  def site_settings_cache_key
    # Use the site settings cache timestamp as part of our cache keys
    SiteSetting.all_as_hash.values.join.hash.abs.to_s(36)
  end
end
