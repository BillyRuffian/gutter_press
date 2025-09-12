class FeedsController < ApplicationController
  allow_unauthenticated_access

  def show
    @posts = Post.published.order(published_at: :desc).limit(20)

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
