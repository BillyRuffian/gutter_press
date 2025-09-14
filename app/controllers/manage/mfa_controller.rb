class Manage::MfaController < ApplicationController
  before_action :require_authentication
  before_action :set_user
  layout 'manage'

  def show
    # Show current MFA status
  end

  def new
    # Setup MFA - Step 1: Generate secret and show QR code
    @user.generate_mfa_secret! unless @user.mfa_secret.present?
    @qr_code_uri = @user.qr_code_uri
    @qr_code = generate_qr_code(@qr_code_uri) if @qr_code_uri
  end

  def create
    # Setup MFA - Step 2: Verify code and enable MFA
    code = params[:mfa_code]

    if @user.verify_mfa_code(code)
      @user.enable_mfa!
      @backup_codes = @user.generate_backup_codes!
      render :backup_codes
    else
      @qr_code_uri = @user.qr_code_uri
      @qr_code = generate_qr_code(@qr_code_uri) if @qr_code_uri
      flash.now[:alert] = 'Invalid verification code. Please try again.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # Disable MFA
    if @user.authenticate(params[:current_password])
      @user.disable_mfa!
      redirect_to manage_mfa_path, notice: 'Two-factor authentication has been disabled.'
    else
      flash[:alert] = 'Incorrect password.'
      redirect_to manage_mfa_path
    end
  end

  def regenerate_backup_codes
    # Generate new backup codes
    if @user.authenticate(params[:current_password])
      @backup_codes = @user.generate_backup_codes!
      render :backup_codes
    else
      flash[:alert] = 'Incorrect password.'
      redirect_to manage_mfa_path
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def generate_qr_code(uri)
    qr = RQRCode::QRCode.new(uri)
    qr.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 6,
      standalone: true
    )
  end
end
