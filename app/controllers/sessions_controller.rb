require "bcrypt"

class SessionsController < ApplicationController
  DUMMY_PASSWORD_DIGEST = ::BCrypt::Password.create(SecureRandom.hex(32))
  private_constant :DUMMY_PASSWORD_DIGEST

  rate_limit to: 5, within: 1.minute, by: -> { request.remote_ip }, with: :rate_limited, only: :create

  def new; end

  def create
    password = params[:password].to_s
    user = User.find_by(login_id: params[:login_id])

    if user&.authenticate(password)
      reset_session
      session[:user_id] = user.id
      redirect_to profile_path
    else
      ::BCrypt::Password.new(DUMMY_PASSWORD_DIGEST) == password unless user
      failed_login
    end
  end

  private

  def rate_limited
    failed_login
  end

  def failed_login
    reset_session
    redirect_to sign_up_path, alert: "ログインできなかったため、新規登録してください。"
  end
end
