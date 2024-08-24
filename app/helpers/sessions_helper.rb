# frozen_string_literal: true

module SessionsHelper
  def session_user
    @session_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    session_user.present?
  end

  def session_user_admin?
    session_user.is_a?(Admin) && session_user.active?
  end
end
