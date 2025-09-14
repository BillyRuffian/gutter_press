class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :postables, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :pages, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # MFA (Multi-Factor Authentication) methods
  def generate_mfa_secret!
    self.mfa_secret = ROTP::Base32.random
    save!
  end

  def totp
    @totp ||= ROTP::TOTP.new(mfa_secret, issuer: 'GutterPress') if mfa_secret.present?
  end

  def verify_mfa_code(code)
    return false unless mfa_enabled? && mfa_secret.present?

    # Try backup code first
    return true if verify_backup_code(code)

    # Then try TOTP code
    totp&.verify(code, drift_ahead: 15, drift_behind: 15)
  end

  # For setup/verification during MFA enrollment
  def verify_setup_code(code)
    return false unless mfa_secret.present?
    totp&.verify(code, drift_ahead: 15, drift_behind: 15)
  end

  def generate_backup_codes!
    codes = Array.new(10) { SecureRandom.hex(5).upcase }
    encrypted_codes = codes.map { |code| BCrypt::Password.create(code) }
    self.backup_codes = JSON.generate(encrypted_codes)
    save!
    codes # Return plain codes for one-time display
  end

  def backup_codes_remaining
    return 0 unless backup_codes.present?
    JSON.parse(backup_codes).length
  end

  def verify_backup_code(code)
    return false unless backup_codes.present?

    codes = JSON.parse(backup_codes)
    codes.each_with_index do |encrypted_code, index|
      if BCrypt::Password.new(encrypted_code) == code.to_s
        # Remove used backup code
        codes.delete_at(index)
        self.backup_codes = JSON.generate(codes)
        save!
        return true
      end
    end
    false
  end

  def qr_code_uri
    return nil unless mfa_secret.present?
    totp&.provisioning_uri(email_address)
  end

  def enable_mfa!
    self.mfa_enabled = true
    save!
  end

  def disable_mfa!
    self.mfa_enabled = false
    self.mfa_secret = nil
    self.backup_codes = nil
    save!
  end
end
