# frozen_string_literal: true

# Custom Active Storage variants controller for CDN-friendly serving
class ActiveStorage::VariantsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  def show
    expires_in ActiveStorage.urls_expire_in, public: true

    # Set CDN-friendly cache headers for variants
    response.headers['Cache-Control'] = 'public, max-age=31536000, immutable'
    response.headers['Vary'] = 'Accept'

    variant = @blob.variant(params[:variation_key])

    if variant.processed?
      # If variant is already processed, redirect to it
      redirect_to variant.url, allow_other_host: true
    else
      # Process variant on-demand and serve it
      send_variant_stream variant
    end
  end

  private

  def send_variant_stream(variant)
    variant.process unless variant.processed?

    send_data variant.download,
              type: variant.blob.content_type,
              disposition: :inline,
              filename: "#{variant.blob.filename.base}.#{variant.blob.filename.extension}"
  end
end
