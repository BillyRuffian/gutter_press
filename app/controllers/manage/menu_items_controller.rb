class Manage::MenuItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_menu_item, only: [ :show, :edit, :update, :destroy ]
  layout 'manage'

  def index
    @menu_items = MenuItem.for_admin
    @available_pages = Page.published.where.not(id: MenuItem.pluck(:page_id)).order(:title)
  end

  def show
  end

  def new
    @menu_item = MenuItem.new
    @menu_item.position = MenuItem.next_position
    @available_pages = Page.published.where.not(id: MenuItem.pluck(:page_id)).order(:title)

    if @available_pages.empty?
      redirect_to manage_menu_items_path, alert: 'No available pages to add to menu. All published pages are already in the menu.'
      nil
    end
  end

  def edit
    @available_pages = Page.published.where.not(id: MenuItem.where.not(id: @menu_item.id).pluck(:page_id)).order(:title)
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)
    @menu_item.position = MenuItem.next_position if @menu_item.position.blank?

    if @menu_item.save
      redirect_to manage_menu_items_path, notice: 'Menu item was successfully created.'
    else
      @available_pages = Page.published.where.not(id: MenuItem.pluck(:page_id)).order(:title)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @menu_item.update(menu_item_params)
      redirect_to manage_menu_items_path, notice: 'Menu item was successfully updated.'
    else
      @available_pages = Page.published.where.not(id: MenuItem.where.not(id: @menu_item.id).pluck(:page_id)).order(:title)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy!
    redirect_to manage_menu_items_path, notice: 'Menu item was successfully removed.', status: :see_other
  end

  def reorder
    if params[:item_positions].present?
      MenuItem.reorder!(params[:item_positions].to_unsafe_h)
      render json: { status: 'success' }
    else
      render json: { status: 'error', message: 'No positions provided' }
    end
  end

  private

  def set_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:page_id, :position, :enabled)
  end
end
