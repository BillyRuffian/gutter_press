class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_post, only: %i[ show ]

  # GET /posts or /posts.json
  def index
    @pagy, @posts = pagy(Post.where('published_at <= ?', Time.now).order(published_at: :desc))
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :published_at, :content ])
    end
end
