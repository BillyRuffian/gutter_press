class SitemapController < ApplicationController
  allow_unauthenticated_access

  def show
    @posts = Post.where('published_at <= ?', Time.current)
                 .order(:published_at)

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
