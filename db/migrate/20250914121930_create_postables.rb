class CreatePostables < ActiveRecord::Migration[8.1]
  def change
    create_table :postables do |t|
      t.string :title
      t.boolean :published
      t.datetime :published_at
      t.references :user, null: false, foreign_key: true
      t.string :type

      t.timestamps
    end
    add_index :postables, :published
    add_index :postables, :published_at
    add_index :postables, :type
    add_index :postables, [ :user_id, :type ]
  end
end
