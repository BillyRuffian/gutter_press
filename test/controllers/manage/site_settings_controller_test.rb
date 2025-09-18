require 'test_helper'

class Manage::SiteSettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
  end

  test 'should get show' do
    get manage_site_settings_url
    assert_response :success
    assert_includes response.body, 'Site Settings'
  end

  test 'should get edit' do
    get edit_manage_site_settings_url
    assert_response :success
    assert_includes response.body, 'Edit Site Settings'
  end

  test 'should update site settings' do
    patch manage_site_settings_url, params: {
      site_settings: {
        site_name: 'Updated Site Name',
        site_description: 'Updated description'
      }
    }

    assert_redirected_to manage_site_settings_url
    follow_redirect!

    # Verify the settings were updated
    assert_equal 'Updated Site Name', SiteSetting.site_name
    assert_equal 'Updated description', SiteSetting.site_description

    # Clean up - reset to defaults
    SiteSetting.set('site_name', 'Gutter Press')
    SiteSetting.set('site_description', 'A modern blogging platform')
  end
end
