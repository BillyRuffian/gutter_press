class SearchController < ApplicationController
  allow_unauthenticated_access only: :index
  def index
    @query = params[:q]
    @search_service = SearchService.new(@query).perform

    # Paginate the results
    @pagy, @results = pagy(:offset, @search_service.results, limit: SiteSetting.posts_per_page)
    @results_count = @search_service.results.length
  end
end
