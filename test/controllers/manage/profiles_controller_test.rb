require 'test_helper'

class Manage::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test 'should show profile' do
    get manage_profile_url
    assert_response :success
    assert_select 'h2', text: 'Profile'
    assert_select '.col-sm-9', text: @user.email_address
  end

  test 'should get edit' do
    get edit_manage_profile_url
    assert_response :success
    assert_select 'h2', text: 'Edit Profile'
  end

  test 'should update email address with current password' do
    patch manage_profile_url, params: {
      user: {
        email_address: 'new@example.com',
        current_password: 'password'
      }
    }
    assert_redirected_to manage_profile_url
    assert_equal 'Profile updated successfully.', flash[:notice]
    @user.reload
    assert_equal 'new@example.com', @user.email_address
  end

  test 'should update password with current password' do
    patch manage_profile_url, params: {
      user: {
        current_password: 'password',
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }
    }
    assert_redirected_to manage_profile_url
    assert_equal 'Password updated successfully.', flash[:notice]
    @user.reload
    assert @user.authenticate('newpassword')
  end

  test 'should not update without current password' do
    sign_in_as(@user)

    patch manage_profile_path, params: {
      user: { email: 'new@example.com' },
      action_type: 'profile'
    }

    assert_response :unprocessable_entity
    assert_match(/Current password is required/, response.body)
  end

  test 'should not update with wrong current password' do
    patch manage_profile_url, params: {
      user: {
        current_password: 'wrongpassword',
        password: 'newpassword',
        password_confirmation: 'newpassword'
      }
    }
    assert_response :unprocessable_entity
    assert_select '.alert-danger', text: /Current password is incorrect/
  end

  test 'should not update password if confirmation does not match' do
    patch manage_profile_url, params: {
      user: {
        current_password: 'password',
        password: 'newpassword',
        password_confirmation: 'differentpassword'
      }
    }
    assert_response :unprocessable_entity
  end

  test 'should require authentication' do
    sign_out
    get manage_profile_url
    assert_redirected_to new_session_url
  end

  private

  def sign_in_as(user)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end

  def sign_out
    delete session_url
  end
end
