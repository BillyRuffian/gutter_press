class LinksController < ApplicationController
  def index
    @postables = search_postables(params[:query])
    render layout: false
  end

  private

  def search_postables(query)
    return Postable.none if query.blank?

    # Search both title and slug with case-insensitive matching
    # Limit to published items and order by type (pages first) then title
    Postable
      .where(publish: true)
      .where('LOWER(title) LIKE ? OR LOWER(slug) LIKE ?',
             "%#{query.downcase}%", "%#{query.downcase}%")
      .order(:type, :title)
      .limit(10) # Limit results for performance
  end
end
