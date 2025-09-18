class PostsController < ApplicationController
  include CacheHelper

  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_post, only: :show

  # GET /posts or /posts.json
  def index
    @pagy, @posts = pagy(Post.published.order(published_at: :desc), limit: SiteSetting.posts_per_page)
  end

  # GET /posts/1 or /posts/1.json
  def show
    # If post is not published and user is not logged in, return 404
    if !@post.published? && !authenticated?
      raise ActiveRecord::RecordNotFound
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find_by!(slug: params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :published_at, :content ])
    end
end
