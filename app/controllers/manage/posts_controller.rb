class Manage::PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_authentication
  layout 'manage'

  def index
    @pagy, @posts = pagy(Post.order(created_at: :desc))
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
    respond_to do |format|
      if @post.update(post_params)
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
      params.expect(post: [ :title, :slug, :excerpt, :publish, :published_at, :content ])
    end
end
