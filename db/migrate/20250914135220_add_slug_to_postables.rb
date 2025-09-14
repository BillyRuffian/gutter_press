class AddSlugToPostables < ActiveRecord::Migration[8.1]
  def change
    add_column :postables, :slug, :string
    add_index :postables, :slug, unique: true
  end
end
