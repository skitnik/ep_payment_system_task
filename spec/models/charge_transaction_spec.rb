# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChargeTransaction, type: :model do
  it 'requires a reference transaction of type AuthorizeTransaction' do
    charge_transaction = build(:charge_transaction, reference_transaction: build(:refund_transaction))
    expect(charge_transaction).to_not be_valid
    expect(charge_transaction.errors[:reference_transaction])
      .to include('must be present and of type AuthorizeTransaction')
  end

  it 'validates that amount does not exceed authorized amount' do
    charge_transaction = build(:charge_transaction, amount: 150.0)
    expect(charge_transaction).to_not be_valid
    expect(charge_transaction.errors[:amount]).to include('cannot exceed the amount of the AuthorizeTransaction')
  end
end
