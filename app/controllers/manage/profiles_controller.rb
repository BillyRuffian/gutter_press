class Manage::ProfilesController < ApplicationController
  before_action :require_authentication
  before_action :set_user
  layout 'manage'

  def show
  end

  def edit
  end

  def update
    if params[:user][:password].present?
      update_password
    else
      update_profile
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def update_profile
    current_password = params[:user][:current_password]

    if current_password.blank?
      @user.errors.add(:current_password, 'is required')
      render :edit, status: :unprocessable_entity
    elsif @user.authenticate(current_password)
      if @user.update(profile_params)
        redirect_to manage_profile_path, notice: 'Profile updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      @user.errors.add(:current_password, 'is incorrect')
      render :edit, status: :unprocessable_entity
    end
  end

  def update_password
    current_password = params[:user][:current_password]

    if current_password.blank?
      @user.errors.add(:current_password, 'is required')
      render :edit, status: :unprocessable_entity
    elsif @user.authenticate(current_password)
      if @user.update(password_params)
        redirect_to manage_profile_path, notice: 'Password updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      @user.errors.add(:current_password, 'is incorrect')
      render :edit, status: :unprocessable_entity
    end
  end

  def profile_params
    params.require(:user).permit(:email_address)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
