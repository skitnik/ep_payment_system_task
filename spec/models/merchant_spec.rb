# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Merchant, type: :model do
  it 'inherits from User' do
    expect(Merchant.ancestors).to include(User)
  end

  it { should have_many(:transactions).dependent(:restrict_with_error) }

  describe '#total_transaction_sum' do
    let!(:merchant) { create(:merchant) }

    it 'calculates the sum of approved charge transactions' do
      reference_transaction = create(:authorize_transaction, merchant:, amount: 600)
      create(:charge_transaction, merchant:, amount: 200, reference_transaction:)
      create(:charge_transaction, merchant:, amount: 200, reference_transaction:)

      expect(merchant.total_transaction_sum).to eq(400)
    end

    it 'returns 0 if there are no approved charge transactions' do
      merchant.transactions.each { |transaction| transaction.update!(status: :reversed) }

      expect(merchant.total_transaction_sum).to eq(0)
    end
  end

  describe 'deletion restrictions' do
    let!(:merchant) { create(:merchant) }

    it 'cannot be deleted if there are associated transactions' do
      create(:authorize_transaction, merchant:)

      expect { merchant.destroy }.to_not change(Merchant, :count)
      expect(merchant.errors[:base]).to include('Cannot delete record because dependent transactions exist')
    end

    it 'can be deleted if there are no associated transactions' do
      expect { merchant.destroy }.to change(Merchant, :count).by(-1)
    end
  end
end
