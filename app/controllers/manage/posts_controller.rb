class Manage::PostsController < ApplicationController
  before_action :require_authentication
  layout 'manage'

  def index
    @pagy, @posts = pagy(Post.order(created_at: :desc))
  end
end
