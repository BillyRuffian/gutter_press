# Configure Action Text to handle video attachments
Rails.application.configure do
  # Add video content types to Action Text allowed content types
  config.active_storage.variant_processor = :mini_magick
  
  # Ensure video content types are properly handled
  config.active_storage.video_preview_arguments = {
    time: 1.0,
    resize_to_limit: [800, 600],
    format: "png"
  }
end