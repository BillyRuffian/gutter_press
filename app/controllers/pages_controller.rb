class PagesController < ApplicationController
  include CacheHelper

  allow_unauthenticated_access only: :show
  before_action :set_page, only: :show

  # GET /pages/1 or /pages/1.json
  def show
    # If page is not published and user is not logged in, return 404
    if !@page.published? && !authenticated?
      raise ActiveRecord::RecordNotFound
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = Page.find_by!(slug: params.expect(:id))
  end
end
