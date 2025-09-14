require 'test_helper'

class UserMfaTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      email_address: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  test 'should generate MFA secret' do
    assert_nil @user.mfa_secret
    @user.generate_mfa_secret!
    @user.reload
    assert_not_nil @user.mfa_secret
    assert_equal 32, @user.mfa_secret.length
  end

  test 'should create TOTP instance' do
    @user.generate_mfa_secret!
    totp = @user.totp
    assert_not_nil totp
    assert_instance_of ROTP::TOTP, totp
    assert_equal 'GutterPress', totp.issuer
  end

  test 'should return nil TOTP when no secret' do
    assert_nil @user.totp
  end

  test 'should verify valid MFA code' do
    @user.generate_mfa_secret!
    @user.enable_mfa!

    code = @user.totp.now
    assert @user.verify_mfa_code(code)
  end

  test 'should reject invalid MFA code' do
    @user.generate_mfa_secret!
    @user.enable_mfa!

    assert_not @user.verify_mfa_code('000000')
  end

  test 'should reject MFA code when MFA disabled' do
    @user.generate_mfa_secret!
    # Note: MFA is not enabled

    code = @user.totp.now
    assert_not @user.verify_mfa_code(code)
  end

  test 'should generate backup codes' do
    backup_codes = @user.generate_backup_codes!

    assert_equal 10, backup_codes.length
    backup_codes.each do |code|
      assert_equal 10, code.length
      assert_match(/\A[A-Z0-9]+\z/, code)
    end

    @user.reload
    assert_not_nil @user.backup_codes
    parsed_codes = JSON.parse(@user.backup_codes)
    assert_equal 10, parsed_codes.length
  end

  test 'should verify backup code' do
    @user.generate_mfa_secret!
    @user.enable_mfa!
    backup_codes = @user.generate_backup_codes!

    assert @user.verify_mfa_code(backup_codes.first)
  end

  test 'should remove used backup code' do
    @user.generate_mfa_secret!
    @user.enable_mfa!
    backup_codes = @user.generate_backup_codes!
    initial_count = @user.backup_codes_remaining

    @user.verify_mfa_code(backup_codes.first)

    assert_equal initial_count - 1, @user.backup_codes_remaining
    # Should not work again
    assert_not @user.verify_mfa_code(backup_codes.first)
  end

  test 'should count remaining backup codes' do
    assert_equal 0, @user.backup_codes_remaining

    @user.generate_backup_codes!
    assert_equal 10, @user.backup_codes_remaining
  end

  test 'should generate QR code URI' do
    @user.generate_mfa_secret!
    uri = @user.qr_code_uri

    assert_not_nil uri
    assert_includes uri, 'otpauth://totp/'
    assert_includes uri, CGI.escape(@user.email_address)
    assert_includes uri, 'GutterPress'
    assert_includes uri, @user.mfa_secret
  end

  test 'should return nil QR code URI when no secret' do
    assert_nil @user.qr_code_uri
  end

  test 'should enable MFA' do
    assert_not @user.mfa_enabled?
    @user.enable_mfa!
    @user.reload
    assert @user.mfa_enabled?
  end

  test 'should disable MFA' do
    @user.generate_mfa_secret!
    @user.enable_mfa!
    @user.generate_backup_codes!

    @user.disable_mfa!
    @user.reload

    assert_not @user.mfa_enabled?
    assert_nil @user.mfa_secret
    assert_nil @user.backup_codes
  end

  test 'should handle missing backup codes gracefully' do
    assert_not @user.verify_backup_code('TESTCODE')
    assert_equal 0, @user.backup_codes_remaining
  end
end
