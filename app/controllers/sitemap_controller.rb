class SitemapController < ApplicationController
  allow_unauthenticated_access

  def show
    @posts = Post.published.order(:published_at)
    @pages = Page.published.order(:published_at)

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
