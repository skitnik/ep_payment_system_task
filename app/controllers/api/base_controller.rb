# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include XmlHelper

    before_action :authenticate_api_token!
    skip_before_action :verify_authenticity_token

    def authenticate_api_token!
      token = request.headers['Authorization']&.split(' ')&.last
      decoded_token = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded_token[:user_id]) if decoded_token

      respond_with_result({ error: 'Unauthorized' }, status: :unauthorized) unless @current_user
    end

    private

    def respond_with_result(result, status: :ok)
      respond_to do |format|
        format.json { render json: result, status: }
        format.xml  { render xml: result.to_xml(root: respond_root_element), status: }
        format.any  { head :not_acceptable }
      end
    end

    def respond_root_element
      'base_controller'
    end
  end
end
