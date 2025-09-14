require 'test_helper'

class MfasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email_address: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
    @user.generate_mfa_secret!
    @user.enable_mfa!
  end

  test 'should redirect to sign in if no pending MFA user' do
    get mfa_path
    assert_redirected_to new_session_path
    assert_match(/Please sign in first/, flash[:alert])
  end

  test 'should show MFA verification form when pending user exists' do
    # Simulate user sign-in that triggers MFA requirement
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    assert_redirected_to mfa_path
    follow_redirect!
    assert_response :success
    assert_select 'input[name="mfa_code"]'
  end

  test 'should verify MFA code and complete sign in' do
    # Sign in to get pending MFA state
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    code = @user.totp.now
    post mfa_path, params: { mfa_code: code }

    assert_redirected_to root_path
    assert_match(/Successfully signed in/, flash[:notice])
  end

  test 'should verify backup code and complete sign in' do
    backup_codes = @user.generate_backup_codes!

    # Sign in to get pending MFA state
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    post mfa_path, params: { mfa_code: backup_codes.first }

    assert_redirected_to root_path
    assert_match(/Successfully signed in/, flash[:notice])
  end

  test 'should reject invalid MFA code' do
    # Sign in to get pending MFA state
    post session_path, params: {
      email_address: @user.email_address,
      password: 'password123'
    }

    post mfa_path, params: { mfa_code: '000000' }

    assert_redirected_to mfa_path
    assert_match(/Invalid verification code/, flash[:alert])
  end
end
