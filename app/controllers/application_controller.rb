# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include SessionsHelper

  def require_login
    return if logged_in?

    flash[:alert] = 'You need to log in to access this page.'
    redirect_to login_path
  end
end
