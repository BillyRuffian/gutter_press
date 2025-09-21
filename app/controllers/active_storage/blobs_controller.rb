# frozen_string_literal: true

# Custom Active Storage blobs controller for CDN-friendly serving
class ActiveStorage::BlobsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  def show
    expires_in ActiveStorage.urls_expire_in, public: true

    # Set CDN-friendly cache headers
    response.headers['Cache-Control'] = 'public, max-age=31536000, immutable'
    response.headers['Vary'] = 'Accept'

    if @blob.content_type.start_with?('image/')
      # For images, we can serve them directly
      redirect_to @blob.url, allow_other_host: true
    else
      # For other files, stream them
      send_blob_stream @blob, disposition: params[:disposition]
    end
  end

  private

  def send_blob_stream(blob, disposition: nil)
    disposition ||= blob.content_type.in?(INLINE_CONTENT_TYPES) ? :inline : :attachment

    send_data blob.download,
              type: blob.content_type,
              disposition: disposition,
              filename: blob.filename.to_s
  end

  INLINE_CONTENT_TYPES = %w[
    image/png
    image/jpeg
    image/jpg
    image/gif
    image/webp
    image/svg+xml
    text/plain
    application/pdf
  ].freeze
end
