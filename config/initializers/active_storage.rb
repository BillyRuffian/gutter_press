# Use rails_storage_proxy for stable URLs
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy

# Configure URLs to be more CDN-friendly
Rails.application.config.active_storage.urls_expire_in = 1.year

# For production, we want public URLs without signed parameters for CDN caching
if Rails.env.production?
  # Override Active Storage URL generation for public blobs
  Rails.application.config.active_storage.draw_routes = true

  # Set variant processor for image processing
  Rails.application.config.active_storage.variant_processor = :vips
end
