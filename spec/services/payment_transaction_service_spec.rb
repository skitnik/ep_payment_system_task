# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentTransactionService, type: :service do
  let(:user) { create(:merchant, email: 'test@merchant.com') }

  let(:fixture_path) { Rails.root.join('spec/fixtures/files/payments.yml') }
  let(:payment_attributes) { YAML.load_file(fixture_path) }

  let(:authorize_payment_params) { payment_attributes['authorize_payment'] }
  let(:charge_payment_params) { payment_attributes['charge_payment'] }
  let(:refund_payment_params) { payment_attributes['refund_payment'] }
  let(:reversal_payment_params) { payment_attributes['reversal_payment'] }

  describe '#create_transaction' do
    context 'when transaction_type is authorize' do
      it 'creates an AuthorizeTransaction and returns success' do
        service = PaymentTransactionService.new(params: authorize_payment_params, user:)
        result = service.create_transaction

        expect(result[:success]).to be true
        expect(result[:transaction]).to be_an_instance_of(AuthorizeTransaction)
        expect(result[:transaction].amount).to eq(authorize_payment_params['amount'])
        expect(result[:transaction].merchant).to eq(user)
      end
    end

    context 'when transaction_type is charge' do
      let!(:authorize_transaction) { create(:authorize_transaction) }

      it 'creates a ChargeTransaction and returns success' do
        service = PaymentTransactionService.new(params: charge_payment_params, user:)
        result = service.create_transaction

        expect(result[:success]).to be true
        expect(result[:transaction]).to be_an_instance_of(ChargeTransaction)
        expect(result[:transaction].amount).to eq(charge_payment_params['amount'])
        expect(result[:transaction].merchant).to eq(user)
        expect(user.total_transaction_sum).to eq(charge_payment_params['amount'])
      end
    end

    context 'when transaction_type is refund' do
      let!(:authorize_transaction) { create(:authorize_transaction, merchant: user) }
      let!(:charge_transaction) { create(:charge_transaction, reference_transaction: authorize_transaction) }

      it 'creates a RefundTransaction and returns success' do
        service = PaymentTransactionService.new(params: refund_payment_params, user:)
        result = service.create_transaction

        expect(result[:success]).to be true
        expect(result[:transaction]).to be_an_instance_of(RefundTransaction)
        expect(result[:transaction].amount).to eq(refund_payment_params['amount'])
        expect(result[:transaction].merchant).to eq(user)
        expect(charge_transaction.reload.status).to eq('refunded')
      end
    end

    context 'when transaction_type is reversal' do
      let!(:authorize_transaction) { create(:authorize_transaction, merchant: user) }

      it 'creates a ReversalTransaction and returns success' do
        service = PaymentTransactionService.new(params: reversal_payment_params, user:)
        result = service.create_transaction

        expect(result[:success]).to be true
        expect(result[:transaction]).to be_an_instance_of(ReversalTransaction)
        expect(result[:transaction].amount).to eq(0)
        expect(result[:transaction].merchant).to eq(user)
        expect(authorize_transaction.reload.status).to eq('reversed')
      end
    end

    context 'when transaction_type is missing' do
      it 'returns an error indicating that transaction_type is required' do
        service = PaymentTransactionService.new(params: authorize_payment_params.except('transaction_type'), user:)
        result = service.create_transaction

        expect(result[:success]).to be false
        expect(result[:error]).to eq('transaction_type is required')
      end
    end

    context 'when transaction save fails' do
      let(:transaction) { instance_double('AuthorizeTransaction', save: false, errors: 'Some error') }

      before do
        allow(AuthorizeTransaction).to receive(:new).and_return(transaction)
      end

      it 'returns an error indicating that transaction could not be saved' do
        service = PaymentTransactionService.new(params: authorize_payment_params, user:)
        result = service.create_transaction

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Some error')
      end
    end
  end
end
