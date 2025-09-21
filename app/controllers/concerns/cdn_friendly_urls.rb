# frozen_string_literal: true

# Concern for generating CDN-friendly Active Storage URLs
module CdnFriendlyUrls
  extend ActiveSupport::Concern

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

  # Generate a stable URL with transformation parameters
  def cdn_image_url_for(attachment, transformations = {}, **options)
    return unless attachment&.attached?
    return unless attachment.image?

    if transformations.present?
      variant = attachment.variant(transformations)
      cdn_variant_url_for(variant, **options)
    else
      cdn_url_for(attachment, **options)
    end
  end
end