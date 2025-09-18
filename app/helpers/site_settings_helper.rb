module SiteSettingsHelper
  # Primary helper method to access site settings in views
  def site_setting(key)
    SiteSetting.get(key)
  end

  # Convenience methods for commonly used settings
  def site_name
    SiteSetting.site_name
  end

  def site_description
    SiteSetting.site_description
  end

  def site_tagline
    SiteSetting.site_tagline
  end

  def footer_text
    SiteSetting.footer_text
  end

  # Boolean helper
  def comments_allowed?
    SiteSetting.allow_comments?
  end

  # Social media helpers
  def twitter_url
    twitter = SiteSetting.get('social_twitter')
    twitter.present? ? "https://twitter.com/#{twitter}" : nil
  end

  def github_url
    github = SiteSetting.get('social_github')
    github.present? ? "https://github.com/#{github}" : nil
  end

  def linkedin_url
    linkedin = SiteSetting.get('social_linkedin')
    linkedin.present? ? "https://linkedin.com/in/#{linkedin}" : nil
  end

  # Contact email helper
  def contact_email
    email = SiteSetting.get('contact_email')
    email.present? ? email : nil
  end

  # Analytics code helper
  def analytics_code
    SiteSetting.get('analytics_code')
  end
end
