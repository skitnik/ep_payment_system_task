# frozen_string_literal: true

module Api
  class AuthenticationController < Api::BaseController
    skip_before_action :authenticate_api_token!

    def create
      user = User.find_by(email: user_params[:email])
      if user&.authenticate(user_params[:password])
        token = JsonWebToken.encode(user_id: user.id)
        respond_with_result({ token: }, status: :ok)
      else
        respond_with_result({ error: 'Invalid email or password' }, status: :unauthorized)
      end
    end

    private

    def user_params
      @user_params ||= if request.format.xml?
                         extract_xml_params(request.body.read, permitted_params)
                       else
                         params.require(:user).permit(permitted_params)
                       end
    end

    def permitted_params
      %i[email password]
    end

    def respond_root_element
      'auth'
    end
  end
end
