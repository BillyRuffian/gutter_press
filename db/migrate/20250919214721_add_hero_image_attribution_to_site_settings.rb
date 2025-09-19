class AddHeroImageAttributionToSiteSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :site_settings, :hero_image_attribution, :text
  end
end
