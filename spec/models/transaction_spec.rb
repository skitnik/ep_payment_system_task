# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:merchant) { create(:merchant) }

  before { FactoryBot.create(:transaction, merchant:) }

  it { should belong_to(:merchant) }
  it { should belong_to(:reference_transaction).class_name('Transaction').optional }

  it { should validate_presence_of(:uuid) }
  it { should validate_uniqueness_of(:uuid) }
  it { should validate_presence_of(:customer_email) }

  it { should allow_value('email@domain.com').for(:customer_email) }
  it { should_not allow_value('invalid_email').for(:customer_email) }

  describe 'scopes' do
    let!(:approved_charge) { create(:charge_transaction, merchant:) }

    it 'returns only approved charges' do
      expect(Transaction.approved_charges).to include(approved_charge)
    end
  end

  describe '#set_initial_status' do
    context 'when no reference transaction is provided' do
      it 'sets the status to approved' do
        transaction = build(:transaction, merchant:, reference_transaction: nil)
        transaction.save
        expect(transaction.status).to eq('approved')
      end
    end

    context 'when reference transaction has a status other than approved or refunded' do
      it 'sets the status to error when the reference transaction is reversed' do
        reference_transaction = create(:authorize_transaction, merchant:, status: :reversed)
        transaction = build(:transaction, merchant:, reference_transaction:)
        transaction.save
        expect(transaction.status).to eq('error')
      end

      it 'sets the status to error when the reference transaction is error' do
        reference_transaction = create(:authorize_transaction, merchant:, status: :error)
        transaction = build(:transaction, merchant:, reference_transaction:)
        transaction.save
        expect(transaction.status).to eq('error')
      end
    end
  end
end
