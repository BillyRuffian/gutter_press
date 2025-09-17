class ProcessCoverImageVariantsJob < ApplicationJob
  queue_as :default

  def perform(postable)
    # Ensure we have a cover image attached
    return unless postable.cover_image.attached?

    Rails.logger.info "Processing cover image variants for #{postable.class.name}##{postable.id}"

    # Generate the thumbnail variant (300x200)
    step :thumbnail do
      thumbnail_variant = postable.cover_image.variant(resize_to_fill: [ 300, 200 ])
      thumbnail_variant.processed
    end

    # Generate the hero variant (1920x1080 max)
    step :hero do
      hero_variant = postable.cover_image.variant(resize_to_limit: [ 1920, 1080 ])
      hero_variant.processed
    end

    Rails.logger.info "Completed processing cover image variants for #{postable.class.name}##{postable.id}"

  rescue => e
    Rails.logger.error "Failed to process cover image variants for #{postable.class.name}##{postable.id}: #{e.message}"
    raise e
  end
end
