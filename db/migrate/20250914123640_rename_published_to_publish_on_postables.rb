class RenamePublishedToPublishOnPostables < ActiveRecord::Migration[8.1]
  def change
    rename_column :postables, :published, :publish
  end
end
