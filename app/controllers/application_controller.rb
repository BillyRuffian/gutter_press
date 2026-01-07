class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  include CdnFriendlyUrls

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Extract page parameter from referrer URL if coming from specified path
  def extract_page_from_referrer(path)
    return nil unless request.referrer&.include?(path)

    referrer_params = Rack::Utils.parse_nested_query(URI.parse(request.referrer).query || '')
    referrer_params['page'] if referrer_params['page'].present?
  end
end
