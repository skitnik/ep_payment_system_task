# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  before { FactoryBot.create(:transaction, type: 'AuthorizeTransaction') }

  it { should belong_to(:merchant) }
  it { should belong_to(:reference_transaction).class_name('Transaction').optional }
  it {
    is_expected.to have_many(:referenced_transactions)
      .class_name('Transaction')
      .with_foreign_key('reference_transaction_id')
  }

  it { should validate_uniqueness_of(:uuid) }
  it { should validate_presence_of(:customer_email) }

  it { should allow_value('email@domain.com').for(:customer_email) }
  it { should_not allow_value('invalid_email').for(:customer_email) }

  describe 'scopes' do
    let!(:approved_charge) { create(:charge_transaction) }

    it 'returns only approved charges' do
      expect(Transaction.approved_charges).to include(approved_charge)
    end
  end

  describe '#set_initial_status' do
    context 'when no reference transaction is provided' do
      it 'sets the status to approved' do
        transaction = build(:authorize_transaction, reference_transaction: nil)
        transaction.save
        expect(transaction.status).to eq('approved')
      end
    end

    context 'when reference transaction has a status other than approved or refunded' do
      it 'sets the status to error when the reference transaction is reversed' do
        reference_transaction = create(:authorize_transaction, status: :reversed)
        transaction = build(:transaction, reference_transaction:)
        transaction.save
        expect(transaction.status).to eq('error')
      end

      it 'sets the status to error when the reference transaction is error' do
        reference_transaction = create(:authorize_transaction, status: :error)
        transaction = build(:transaction, reference_transaction:)
        transaction.save
        expect(transaction.status).to eq('error')
      end
    end
  end

  describe 'UUID generation' do
    it 'generates a UUID if not provided' do
      transaction = build(:authorize_transaction, uuid: nil)
      transaction.save
      expect(transaction.uuid).not_to be_nil
    end

    it 'does not change an existing UUID' do
      uuid = SecureRandom.uuid
      transaction = create(:authorize_transaction, uuid:)
      transaction.save
      expect(transaction.uuid).to eq(uuid)
    end
  end

  describe 'validations' do
    context 'when type is valid' do
      it 'is valid with an allowed transaction type' do
        Transaction::ALLOWED_TRANSACTION_TYPES.each do |transaction_type|
          transaction = build(:transaction, type: transaction_type)
          expect(transaction).to be_valid
        end
      end
    end

    context 'when type is invalid' do
      it 'is not valid with an invalid transaction type' do
        transaction = build(:transaction, type: 'InvalidTransactionType')
        expect(transaction).not_to be_valid
        expect(transaction.errors[:type])
          .to include("must be one of the following: #{Transaction::ALLOWED_TRANSACTION_TYPES.join(', ')}")
      end
    end
  end
end
