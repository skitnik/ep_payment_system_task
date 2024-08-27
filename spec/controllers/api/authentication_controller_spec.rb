# frozen_string_literal: true

require 'rails_helper'

# frozen_string_literal: true

RSpec.describe Api::AuthenticationController, type: :controller do
  let(:user) { create(:merchant, password: 'password') }

  describe 'POST #create' do
    let(:valid_params) { { user: { email: user.email, password: 'password' } } }
    let(:invalid_params) { { user: { email: user.email, password: 'wrong_password' } } }
    let(:empty_params) { { user: { email: '', password: '' } } }

    shared_examples 'a successful authentication' do |format|
      it "returns a JWT token in #{format.upcase} format" do
        post :create, params: valid_params, as: format

        expect(response).to have_http_status(:ok)
        response_data = parse_response(format)
        expect(response_data['token']).to be_present

        decoded_token = JsonWebToken.decode(response_data['token'])
        expect(decoded_token[:user_id]).to eq(user.id)
      end
    end

    shared_examples 'an unauthorized authentication' do |format|
      it "returns an unauthorized error in #{format.upcase} format" do
        post :create, params: invalid_params, as: format

        expect(response).to have_http_status(:unauthorized)
        response_data = parse_response(format)
        expect(response_data['error']).to eq('Invalid email or password')
      end
    end

    context 'with valid credentials' do
      it_behaves_like 'a successful authentication', :json
      it_behaves_like 'a successful authentication', :xml
    end

    context 'with invalid credentials' do
      it_behaves_like 'an unauthorized authentication', :json
      it_behaves_like 'an unauthorized authentication', :xml
    end

    context 'with missing email or password' do
      it 'returns an unauthorized error in JSON format' do
        post :create, params: empty_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns an unauthorized error in XML format' do
        post :create, params: empty_params, as: :xml

        expect(response).to have_http_status(:unauthorized)
        xml_response = Hash.from_xml(response.body)
        expect(xml_response['auth']['error']).to eq('Invalid email or password')
      end
    end
  end

  private

  def parse_response(format)
    case format
    when :json
      JSON.parse(response.body)
    when :xml
      Hash.from_xml(response.body)['auth']
    else
      raise ArgumentError, "Unsupported format: #{format}"
    end
  end
end
