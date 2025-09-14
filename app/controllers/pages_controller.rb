class PagesController < ApplicationController
  allow_unauthenticated_access only: :show
  before_action :set_page, only: :show

  # GET /pages/1 or /pages/1.json
  def show
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_page
    @page = Page.find_by!(slug: params.expect(:id))
  end
end
