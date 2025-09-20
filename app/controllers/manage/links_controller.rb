class Manage::LinksController < ApplicationController
  def index
    @postables = search_postables(params[:filter])
    render layout: false
  end

  private

  def search_postables(query)
    return Postable.none if query.blank?

    # Search both title and slug with case-insensitive matching
    # Include both published and unpublished items since this is the management interface
    # Order by type (pages first) then title
    p = Postable
      .where('LOWER(title) LIKE ? OR LOWER(slug) LIKE ?',
             "%#{query.downcase}%", "%#{query.downcase}%")
      .order(:type, :title)
      .limit(10) # Limit results for performance

    Rails.logger.info "Search query: #{query}, Results found: #{p.count}"
    p
  end
end
