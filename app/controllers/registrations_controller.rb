class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  layout "marketing"

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    redirect_to desks_path and return if authenticated?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      Desk.provision_home!(@user)
      redirect_to desks_path, notice: "The desk is open."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
    end
end
