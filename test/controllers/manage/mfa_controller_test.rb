require 'test_helper'

class Manage::MfasControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @user = User.create!(
      email_address: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
    sign_in_as(@user)
  end

  test 'should require authentication' do
    sign_out
    get manage_mfa_path
    assert_redirected_to new_session_path
  end

  test 'should show MFA status when disabled' do
    get manage_mfa_path
    assert_response :success
    assert_select '.badge.bg-warning', text: 'Disabled'
    assert_select 'a[href="' + new_manage_mfa_path + '"]', text: 'Enable Two-Factor Authentication'
  end

  test 'should show MFA status when enabled' do
    @user.generate_mfa_secret!
    @user.enable_mfa!
    @user.generate_backup_codes!

    get manage_mfa_path
    assert_response :success
    assert_select '.badge.bg-success', text: 'Enabled'
    assert_select '.alert-success'
  end

  test 'should show MFA setup form' do
    get new_manage_mfa_path
    assert_response :success
    assert_select 'form[action="' + manage_mfa_path + '"]'
    assert_select 'input[name="mfa_code"]'
    assert_not_nil assigns(:qr_code_uri)
    # QR code is now generated in the helper, not assigned in controller
    assert_select 'svg'  # Check that QR code SVG is rendered
  end

  test 'should enable MFA with valid code' do
    # First visit the setup page to generate secret
    get new_manage_mfa_path
    @user.reload

    code = @user.totp.now
    post manage_mfa_path, params: { mfa_code: code }

    assert_response :success
    assert_template :backup_codes
    @user.reload
    assert @user.mfa_enabled?
    assert_not_nil assigns(:backup_codes)
  end

  test 'should not enable MFA with invalid code' do
    # First visit the setup page to generate secret
    get new_manage_mfa_path

    post manage_mfa_path, params: { mfa_code: '000000' }

    assert_response :unprocessable_entity
    assert_template :new
    @user.reload
    assert_not @user.mfa_enabled?
    assert_match(/Invalid verification code/, flash.now[:alert])
  end

  test 'should disable MFA with correct password' do
    @user.generate_mfa_secret!
    @user.enable_mfa!

    delete manage_mfa_path, params: { current_password: 'password123' }

    assert_redirected_to manage_mfa_path
    assert_match(/disabled/, flash[:notice])
    @user.reload
    assert_not @user.mfa_enabled?
    assert_nil @user.mfa_secret
  end

  test 'should not disable MFA with incorrect password' do
    @user.generate_mfa_secret!
    @user.enable_mfa!

    delete manage_mfa_path, params: { current_password: 'wrongpassword' }

    assert_redirected_to manage_mfa_path
    assert_match(/Incorrect password/, flash[:alert])
    @user.reload
    assert @user.mfa_enabled?
  end

  test 'should regenerate backup codes with correct password' do
    @user.generate_mfa_secret!
    @user.enable_mfa!
    @user.generate_backup_codes!
    original_encrypted_codes = @user.backup_codes

    post regenerate_backup_codes_manage_mfa_path, params: { current_password: 'password123' }

    assert_response :success
    assert_template :backup_codes
    @user.reload
    assert_not_equal original_encrypted_codes, @user.backup_codes
    assert_not_nil assigns(:backup_codes)
  end

  test 'should not regenerate backup codes with incorrect password' do
    @user.generate_mfa_secret!
    @user.enable_mfa!
    @user.generate_backup_codes!

    post regenerate_backup_codes_manage_mfa_path, params: { current_password: 'wrongpassword' }

    assert_redirected_to manage_mfa_path
    assert_match(/Incorrect password/, flash[:alert])
  end
end
