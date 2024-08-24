# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new]

  def new; end

  def create
    if user&.authenticate(params[:session][:password]) && user&.active?
      session[:user_id] = user.id
      redirect_user
    else
      flash.now[:alert] = 'The email or password you entered is incorrect, or your account may be inactive.'
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: 'Logged out successfully.'
  end

  private

  def redirect_if_logged_in
    return unless logged_in?

    redirect_user
  end

  def redirect_user
    if session_user_admin?
      redirect_to merchants_path
    else
      redirect_to transactions_path
    end
  end

  def user
    @user ||= User.find_by(email: session_params[:email].downcase)
  end

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
