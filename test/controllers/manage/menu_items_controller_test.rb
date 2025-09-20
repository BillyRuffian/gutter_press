require "test_helper"

class Manage::MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @menu_item = menu_items(:one)
    sign_in_as(users(:one))
  end

  test "should get index" do
    get manage_menu_items_url
    assert_response :success
    assert_select 'h1', 'Menu Management'
  end

  test "should get new" do
    get new_manage_menu_item_url
    assert_response :success
  end

  test "should create menu_item" do
    # Use a page that's not already in the menu
    page = postables(:privacy_page) # Privacy Policy page
    assert_difference('MenuItem.count') do
      post manage_menu_items_url, params: { 
        menu_item: { 
          page_id: page.id,
          enabled: true 
        } 
      }
    end

    assert_redirected_to manage_menu_items_url
  end

  test "should show menu_item" do
    get manage_menu_item_url(@menu_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_manage_menu_item_url(@menu_item)
    assert_response :success
  end

  test "should update menu_item" do
    patch manage_menu_item_url(@menu_item), params: { 
      menu_item: { 
        page_id: @menu_item.page_id,
        enabled: false
      } 
    }
    assert_redirected_to manage_menu_items_url
  end

  test "should destroy menu_item" do
    assert_difference('MenuItem.count', -1) do
      delete manage_menu_item_url(@menu_item)
    end

    assert_redirected_to manage_menu_items_url
  end

  test "should reorder menu items" do
    menu_item_ids = MenuItem.order(:position).pluck(:id)
    # Create a hash mapping item IDs to new positions
    item_positions = {}
    menu_item_ids.reverse.each_with_index do |id, index|
      item_positions[id.to_s] = index + 1
    end

    patch reorder_manage_menu_items_url, params: { 
      item_positions: item_positions 
    }

    assert_response :success
    
    # Check that positions were updated
    first_item = MenuItem.find(menu_item_ids.last)
    first_item.reload
    assert_equal 1, first_item.position
  end

  test "should require authentication" do
    sign_out
    
    get manage_menu_items_url
    assert_redirected_to new_session_url
  end
end