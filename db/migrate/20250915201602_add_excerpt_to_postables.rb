class AddExcerptToPostables < ActiveRecord::Migration[8.1]
  def change
    add_column :postables, :excerpt, :text
  end
end
