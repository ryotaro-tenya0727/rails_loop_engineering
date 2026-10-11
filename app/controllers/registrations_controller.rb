class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to profile_path
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @user.errors.add(:login_id, :taken)
    render :new, status: :unprocessable_entity
  end

  private

  def registration_params
    params.require(:user).permit(:login_id, :password)
  end
end
