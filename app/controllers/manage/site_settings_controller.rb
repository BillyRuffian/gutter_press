class Manage::SiteSettingsController < ApplicationController
  before_action :require_authentication
  layout 'manage'

  def show
    @settings = SiteSetting.all_as_hash
  end

  def edit
    @settings = SiteSetting.all_as_hash
  end

  def update
    success = true

    # Handle regular settings
    if settings_params.present?
      success = SiteSetting.update_multiple(settings_params)
    end

    # Handle hero image upload
    if params[:hero_image].present?
      hero_record = SiteSetting.hero_image_record
      hero_record.hero_image.attach(params[:hero_image])
    end

    # Handle hero image attribution
    if params[:hero_image_attribution]
      SiteSetting.set_hero_image_attribution(params[:hero_image_attribution])
    end

    if success
      redirect_to manage_site_settings_path, notice: 'Site settings were successfully updated.'
    else
      @settings = SiteSetting.all_as_hash
      flash.now[:alert] = 'There was an error updating the settings.'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:site_settings).permit(
      :site_name,
      :site_description,
      :site_tagline,
      :posts_per_page,
      :allow_comments,
      :contact_email,
      :footer_text,
      :social_twitter,
      :social_github,
      :social_linkedin,
      :analytics_code,
      :hero_enabled,
      :hero_title,
      :hero_subtitle
    )
  end
end
