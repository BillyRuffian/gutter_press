class Manage::GutterPressController < ApplicationController
  before_action :require_authentication
  layout 'manage'

  def index
    @total_posts_count = Post.count
    @published_posts_count = Post.where('published_at <= ?', Time.current).count
    @recent_posts = Post.order(created_at: :desc).limit(5)

    @total_pages_count = Page.count
    @published_pages_count = Page.where('published_at <= ?', Time.current).count
    @recent_pages = Page.order(created_at: :desc).limit(5)
  end
end
