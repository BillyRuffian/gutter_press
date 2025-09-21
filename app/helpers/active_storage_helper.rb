# frozen_string_literal: true

# Helper methods for CDN-friendly Active Storage URLs
module ActiveStorageHelper
  # Generate a CDN-friendly URL for an Active Storage attachment
  def cdn_image_tag(attachment, **options)
    return unless attachment&.attached?
    
    # Extract image-specific options
    alt = options.delete(:alt) || ''
    css_class = options.delete(:class) || options.delete('class')
    transformations = options.delete(:resize) || options.delete(:variant)
    
    # Generate the appropriate URL
    if transformations.present? && attachment.image?
      variant = attachment.variant(transformations)
      url = cdn_variant_url_for(variant)
    else
      url = cdn_url_for(attachment)
    end
    
    return unless url
    
    # Generate the image tag with CDN URL
    image_tag url, alt: alt, class: css_class, **options
  end

  # Generate a CDN-friendly link to an Active Storage attachment
  def cdn_link_to(text, attachment, **options)
    return unless attachment&.attached?
    
    url = cdn_url_for(attachment)
    return unless url
    
    link_to text, url, **options
  end

  # Helper for common thumbnail sizes used in the app
  def cdn_thumbnail_tag(attachment, size: :medium, **options)
    return unless attachment&.attached?
    
    transformations = case size
    when :small then { resize_to_fill: [150, 100] }
    when :medium then { resize_to_fill: [300, 200] }
    when :large then { resize_to_fill: [600, 400] }
    when :hero then { resize_to_limit: [1920, 1080] }
    else size.is_a?(Hash) ? size : { resize_to_fill: [300, 200] }
    end
    
    cdn_image_tag(attachment, variant: transformations, **options)
  end

  private

  # Generate a stable, CDN-friendly URL for an Active Storage attachment
  def cdn_url_for(attachment, **options)
    return unless attachment&.attached?

    if Rails.env.production?
      # In production, use stable URLs without expiration
      rails_blob_url(attachment, **options)
    else
      # In development/test, use regular URLs
      url_for(attachment, **options)
    end
  end

  # Generate a stable, CDN-friendly URL for an Active Storage variant
  def cdn_variant_url_for(variant, **options)
    return unless variant&.blob&.attached?

    if Rails.env.production?
      # In production, use stable variant URLs
      rails_blob_url(variant, **options)
    else
      # In development/test, use regular URLs
      url_for(variant, **options)
    end
  end
end