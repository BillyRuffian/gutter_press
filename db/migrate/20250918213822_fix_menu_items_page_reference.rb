class FixMenuItemsPageReference < ActiveRecord::Migration[8.1]
  def change
    # Remove the foreign key constraint to pages table
    remove_foreign_key :menu_items, :pages if foreign_key_exists?(:menu_items, :pages)
    
    # Remove the existing page_id column
    remove_column :menu_items, :page_id, :bigint
    
    # Add page_id column referencing postables table  
    add_reference :menu_items, :page, null: false, foreign_key: { to_table: :postables }, index: { unique: true }
    
    # Remove and recreate the position unique index to handle any existing data
    remove_index :menu_items, :position if index_exists?(:menu_items, :position)
    add_index :menu_items, :position, unique: true
  end
end
