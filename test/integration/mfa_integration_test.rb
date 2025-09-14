require 'test_helper'

class MfaIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  test 'normal sign in flow without MFA' do
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test 'sign in flow with MFA enabled' do
    @user.generate_mfa_secret!
    @user.enable_mfa!

    # Step 1: Sign in with password
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    # Should redirect to MFA verification
    assert_redirected_to mfa_path
    assert_equal @user.id, session[:pending_mfa_user_id]

    # Step 2: Enter MFA code
    follow_redirect!
    assert_response :success
    assert_select 'input[name="mfa_code"]'

    # Step 3: Submit valid MFA code
    code = @user.totp.now
    post mfa_path, params: { mfa_code: code }

    # Should complete sign in
    assert_redirected_to root_path
    assert_nil session[:pending_mfa_user_id]
  end

  test 'sign in flow with backup code' do
    @user.generate_mfa_secret!
    @user.enable_mfa!
    backup_codes = @user.generate_backup_codes!

    # Sign in with password
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    # Use backup code
    post mfa_path, params: { mfa_code: backup_codes.first }

    assert_redirected_to root_path
    assert_nil session[:pending_mfa_user_id]
  end

  test 'complete MFA setup flow' do
    # Sign in first
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }
    follow_redirect!

    # Go to MFA setup
    get new_manage_mfa_path
    assert_response :success
    assert_select 'input[name="mfa_code"]'

    # Generate secret should happen automatically
    @user.reload
    assert_not_nil @user.mfa_secret

    # Submit valid code to enable MFA
    code = @user.totp.now
    post manage_mfa_path, params: { mfa_code: code }

    # Should show backup codes
    assert_response :success
    assert_template 'manage/mfas/backup_codes'

    @user.reload
    assert @user.mfa_enabled?
    assert_equal 10, @user.backup_codes_remaining
  end

  test 'MFA disable flow' do
    @user.generate_mfa_secret!
    @user.enable_mfa!

    # Sign in
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    # Complete MFA verification
    code = @user.totp.now
    post mfa_path, params: { mfa_code: code }
    follow_redirect!

    # Disable MFA
    delete manage_mfa_path, params: { current_password: 'password123' }

    assert_redirected_to manage_mfa_path
    @user.reload
    assert_not @user.mfa_enabled?
  end
end
