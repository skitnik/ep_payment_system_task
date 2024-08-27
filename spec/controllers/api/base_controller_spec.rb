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
    before do
      request.headers['Authorization'] = authorization_header
      post :create, format: :json
    end

    context 'with a valid token' do
      let(:authorization_header) { "Bearer #{valid_token}" }

      it 'returns a success message' do
        expect_successful_response
      end
    end

    context 'with an invalid token' do
      let(:authorization_header) { "Bearer #{invalid_token}" }

      it 'returns an unauthorized status' do
        expect_unauthorized_response
      end
    end

    context 'without a token' do
      let(:authorization_header) { nil }

      it 'returns an unauthorized status' do
        expect_unauthorized_response
      end
    end
  end

  describe 'Response Formats' do
    before do
      request.headers['Authorization'] = "Bearer #{valid_token}"
      post :create, format: requested_format
    end

    context 'when requesting JSON' do
      let(:requested_format) { :json }

      it 'responds with JSON format' do
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect_successful_response
      end
    end

    context 'when requesting XML' do
      let(:requested_format) { :xml }

      it 'responds with XML format' do
        expect(response.content_type).to eq('application/xml; charset=utf-8')
        expect_successful_xml_response
      end
    end

    context 'when requesting an unsupported format' do
      let(:requested_format) { :html }

      it 'responds with not acceptable status' do
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end

  private

  def expect_successful_response
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq('respond' => true)
  end

  def expect_unauthorized_response
    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to eq('error' => 'Unauthorized')
  end

  def expect_successful_xml_response
    parsed_hash = Hash.from_xml(response.body)
    expect(parsed_hash.deep_symbolize_keys).to eq(base_controller: { respond: true })
  end
end
