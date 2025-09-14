class MfaController < ApplicationController
  allow_unauthenticated_access only: %i[ show create ]
  before_action :require_pending_mfa

  def show
    # Show MFA verification form
  end

  def create
    user = User.find(session[:pending_mfa_user_id])
    code = params[:mfa_code]

    if user.verify_mfa_code(code)
      # MFA verification successful
      session.delete(:pending_mfa_user_id)
      start_new_session_for user
      redirect_to after_authentication_url, notice: 'Successfully signed in.'
    else
      redirect_to mfa_path, alert: 'Invalid verification code. Please try again.'
    end
  end

  private

  def require_pending_mfa
    unless session[:pending_mfa_user_id]
      redirect_to new_session_path, alert: 'Please sign in first.'
    end
  end
end
