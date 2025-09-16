class Manage::PagesController < ApplicationController
  before_action :set_page, only: %i[ show edit update destroy ]
  before_action :require_authentication
  layout 'manage'

  def index
    @pagy, @pages = pagy(Page.order(created_at: :desc))
  end

  def new
    @page = Page.new
    @page.published_at = Time.current
  end

  def show
  end

  def create
    @page = Page.new(page_params)
    @page.user = Current.user
    respond_to do |format|
      if @page.save
        format.html { redirect_to manage_page_url(@page), notice: 'Page was successfully created.' }
        format.json { render :show, status: :created, location: manage_page_url(@page) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    # Handle cover image removal
    if params.dig(:page, :remove_cover_image) == '1'
      @page.cover_image.purge
    end
    
    respond_to do |format|
      if @page.update(page_params_without_remove_flag)
        format.html { redirect_to manage_page_url(@page), notice: 'Page was successfully updated.', status: :see_other }
        format.json { render :show, status: :ok, location: manage_page_url(@page) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @page.destroy!

    respond_to do |format|
      format.html { redirect_to manage_pages_path, notice: 'Page was successfully destroyed.', status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find_by!(slug: params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def page_params
      params.expect(page: [ :title, :slug, :excerpt, :publish, :published_at, :content, :cover_image, :cover_image_attribution, :remove_cover_image ])
    end

    def page_params_without_remove_flag
      params.expect(page: [ :title, :slug, :excerpt, :publish, :published_at, :content, :cover_image, :cover_image_attribution ])
    end
end
