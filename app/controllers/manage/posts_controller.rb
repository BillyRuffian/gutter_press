class Manage::PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_authentication
  layout 'manage'

  def index
    # Order unpublished posts first by updated_at, then published posts by published_at desc
    posts_ordered = Post.order(
      Arel.sql("CASE WHEN (publish = 0 OR published_at IS NULL OR published_at > datetime('now')) THEN 0 ELSE 1 END"),
      Arel.sql("CASE WHEN (publish = 0 OR published_at IS NULL OR published_at > datetime('now')) THEN updated_at ELSE published_at END DESC")
    )
    @pagy, @posts = pagy(posts_ordered, limit: SiteSetting.posts_per_page)
  end

  def new
    @post = Post.new
    @post.published_at = Time.current
  end

  def show
  end

  def create
    @post = Post.new(post_params)
    @post.user = Current.user
    respond_to do |format|
      if @post.save
        format.html { redirect_to manage_post_url(@post), notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: manage_post_url(@post) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # Handle cover image removal
    if params.dig(:post, :remove_cover_image) == '1'
      @post.cover_image.purge
    end

    respond_to do |format|
      if @post.update(post_params_without_remove_flag)
        format.html { redirect_to manage_post_url(@post), notice: 'Post was successfully updated.', status: :see_other }
        format.json { render :show, status: :ok, location: manage_post_url(@post) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to manage_posts_path, notice: 'Post was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find_by!(slug: params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :slug, :excerpt, :publish, :published_at, :content, :cover_image, :cover_image_attribution, :remove_cover_image ])
    end

    def post_params_without_remove_flag
      params.expect(post: [ :title, :slug, :excerpt, :publish, :published_at, :content, :cover_image, :cover_image_attribution ])
    end
end
