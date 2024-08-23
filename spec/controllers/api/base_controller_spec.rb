# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::BaseController, type: :controller do
  controller do
    def create
      respond_with_result({ respond: true }, status: :ok)
    end
  end

  let(:user) { create(:merchant) }
  let(:valid_token) { JsonWebToken.encode(user_id: user.id) }
  let(:invalid_token) { 'invalidtoken' }

  describe 'Authentication' do
    context 'with a valid token' do
      before do
        request.headers['Authorization'] = "Bearer #{valid_token}"
        post :create, format: :json
      end

      it 'returns a success message' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq('respond' => true)
      end
    end

    context 'with an invalid token' do
      before do
        request.headers['Authorization'] = "Bearer #{invalid_token}"
        post :create, format: :json
      end

      it 'returns an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq('error' => 'Unauthorized')
      end
    end

    context 'without a token' do
      before do
        post :create, format: :json
      end

      it 'returns an unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq('error' => 'Unauthorized')
      end
    end
  end

  describe 'Response Formats' do
    before do
      request.headers['Authorization'] = "Bearer #{valid_token}"
    end

    context 'when requesting JSON' do
      before { post :create, format: :json }

      it 'responds with JSON format' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq('respond' => true)
      end
    end

    context 'when requesting XML' do
      before { post :create, format: :xml }

      it 'responds with XML format' do
        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect(response).to have_http_status(:ok)

        parsed_hash = Hash.from_xml(response.body)
        expect(parsed_hash.deep_symbolize_keys).to eq(base_controller: { respond: true })
      end
    end

    context 'when requesting an unsupported format' do
      before { post :create, format: :html }

      it 'responds with not acceptable status' do
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end
end
