# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AuthenticationController, type: :controller do
  let(:user) { create(:merchant, password: 'password') }

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'returns a JWT token in JSON format' do
        post :create, params: { user: { email: user.email, password: 'password' } }, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['token']).to be_present

        decoded_token = JsonWebToken.decode(json_response['token'])
        expect(decoded_token[:user_id]).to eq(user.id)
      end

      it 'returns a JWT token in XML format' do
        post :create, params: { user: { email: user.email, password: 'password' } }, as: :xml

        expect(response).to have_http_status(:ok)
        xml_response = Hash.from_xml(response.body)
        expect(xml_response['auth']['token']).to be_present

        decoded_token = JsonWebToken.decode(xml_response['auth']['token'])
        expect(decoded_token[:user_id]).to eq(user.id)
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized error in JSON format' do
        post :create, params: { user: { email: user.email, password: 'wrong_password' } }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns an unauthorized error in XML format' do
        post :create, params: { user: { email: user.email, password: 'wrong_password' } }, as: :xml

        expect(response).to have_http_status(:unauthorized)
        xml_response = Hash.from_xml(response.body)
        expect(xml_response['auth']['error']).to eq('Invalid email or password')
      end
    end

    context 'with missing email or password' do
      it 'returns an unauthorized error in JSON format' do
        post :create, params: { user: { email: '', password: '' } }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns an unauthorized error in XML format' do
        post :create, params: { user: { email: '', password: '' } }, as: :xml

        expect(response).to have_http_status(:unauthorized)
        xml_response = Hash.from_xml(response.body)
        expect(xml_response['auth']['error']).to eq('Invalid email or password')
      end
    end
  end
end
