class AddCoverImageAttributionToPostables < ActiveRecord::Migration[8.1]
  def change
    add_column :postables, :cover_image_attribution, :text
  end
end
