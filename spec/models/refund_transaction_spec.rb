# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefundTransaction, type: :model do
  it 'requires a reference transaction of type ChargeTransaction' do
    refund_transaction = build(:refund_transaction, reference_transaction: build(:authorize_transaction))
    expect(refund_transaction).to_not be_valid
    expect(refund_transaction.errors[:reference_transaction])
      .to include('must be present and of type ChargeTransaction')
  end

  it 'processes refund and updates the charge transaction status to refunded' do
    charge_transaction = create(:charge_transaction)
    create(:refund_transaction, merchant: charge_transaction.merchant, reference_transaction: charge_transaction)
    expect(charge_transaction.reload.status).to eq('refunded')
  end
end
