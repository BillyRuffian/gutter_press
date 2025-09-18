class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.references :page, null: false, foreign_key: true, index: { unique: true }
      t.integer :position, null: false
      t.boolean :enabled, default: true, null: false

      t.timestamps
    end
    
    # Add indexes for performance
    add_index :menu_items, :position, unique: true
    add_index :menu_items, [:enabled, :position], name: 'index_menu_items_on_enabled_and_position'
  end
end
