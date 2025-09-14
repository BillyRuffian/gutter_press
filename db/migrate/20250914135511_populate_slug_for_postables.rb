class PopulateSlugForPostables < ActiveRecord::Migration[8.1]
  def up
    Postable.find_each do |postable|
      if postable.slug.blank?
        postable.update_column(:slug, postable.title.parameterize)
      end
    end
  end

  def down
    # No need to rollback slug population
  end
end
