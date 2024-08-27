# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payments API', type: :request do
  let(:merchant_user) { create(:merchant) }
  let(:inactive_merchant) { create(:merchant, status: :inactive) }
  let(:admin_user) { create(:admin) }

  let(:fixture_path) { Rails.root.join('spec/fixtures/files/payments.yml') }
  let(:payment_attributes) { YAML.load_file(fixture_path) }

  let(:authorize_payment_params) { payment_attributes['authorize_payment'] }
  let(:invalid_payment_json) { payment_attributes['invalid_payment'] }

  let(:payment_service_instance) { instance_double(PaymentTransactionService) }

  before do
    @headers = { 'Authorization' => "Bearer #{JsonWebToken.encode(user_id: merchant_user.id)}" }
    @xml_headers = {
      'Authorization' => "Bearer #{JsonWebToken.encode(user_id: merchant_user.id)}",
      'Content-Type' => 'application/xml',
      'Accept' => 'application/xml'
    }
  end

  describe 'POST /api/payments' do
    context 'with valid JSON parameters' do
      it 'creates a transaction and returns a created status' do
        post '/api/payments', params: { payment: authorize_payment_params }, headers: @headers, as: :json

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['status']).to eq('Payment transaction #1 created')
      end
    end

    context 'with valid XML parameters' do
      it 'creates a transaction and returns a created status' do
        xml_params = File.read(Rails.root.join('spec/fixtures/files/authorize_payment.xml'))

        post '/api/payments', params: xml_params, headers: @xml_headers, as: :xml

        expect(response).to have_http_status(:created)

        parsed_hash = Hash.from_xml(response.body)
        expect(parsed_hash.deep_symbolize_keys).to eq(payment: { status: 'Payment transaction #1 created' })
      end
    end

    context 'with invalid JSON parameters' do
      it 'returns an error and an unprocessable_entity status' do
        post '/api/payments', params: { payment: invalid_payment_json }, headers: @headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('An error occurred: transaction_type is required')
      end
    end

    context 'with invalid XML parameters' do
      it 'returns an error and an unprocessable_entity status' do
        xml_params = File.read(Rails.root.join('spec/fixtures/files/invalid_authorize_payment.xml'))

        post '/api/payments', params: xml_params, headers: @xml_headers, as: :xml

        expect(response).to have_http_status(:unprocessable_entity)

        parsed_hash = Hash.from_xml(response.body)
        expect(parsed_hash.deep_symbolize_keys).to eq(payment: { error: 'Amount must be greater than 0' })
      end
    end

    context 'when unauthorized' do
      before { @headers.delete('Authorization') }

      it 'returns an unauthorized status' do
        post '/api/payments', params: { payment: authorize_payment_params }, headers: @headers, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end

    context 'when the user is inactive' do
      before { @headers['Authorization'] = "Bearer #{JsonWebToken.encode(user_id: inactive_merchant.id)}" }

      it 'returns an unauthorized status' do
        post '/api/payments', params: { payment: authorize_payment_params }, headers: @headers, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end

    context 'when the user is not a merchant' do
      before { @headers['Authorization'] = "Bearer #{JsonWebToken.encode(user_id: admin_user.id)}" }

      it 'returns an unauthorized status' do
        post '/api/payments', params: { payment: authorize_payment_params }, headers: @headers, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
  end
end
