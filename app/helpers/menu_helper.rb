module MenuHelper
  # Get the main navigation menu items (cached)
  def main_menu_items
    MenuItem.active_menu_items
  end

  # Check if any menu items exist
  def has_menu_items?
    main_menu_items.any?
  end

  # Get menu item count
  def menu_items_count
    main_menu_items.count
  end

  # Check if a specific page is in the menu
  def page_in_menu?(page)
    main_menu_items.any? { |item| item[:page_id] == page.id }
  end
end
