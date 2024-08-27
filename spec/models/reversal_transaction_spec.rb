# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReversalTransaction, type: :model do
  it 'requires a reference transaction of type AuthorizeTransaction' do
    reversal_transaction = build(:reversal_transaction, reference_transaction: build(:refund_transaction))
    expect(reversal_transaction).to_not be_valid
    expect(reversal_transaction.errors[:reference_transaction])
      .to include('must be present and of type AuthorizeTransaction')
  end

  it 'validates that the amount is zero or nil for reversal transactions' do
    reversal_transaction = build(:reversal_transaction, amount: 100.0)
    expect(reversal_transaction).to_not be_valid
    expect(reversal_transaction.errors[:amount]).to include('must be 0 or none for reversal transactions')
  end

  it 'reverses the charge transaction and updates the status to reversed' do
    authorize_transaction = create(:authorize_transaction)
    create(:reversal_transaction, reference_transaction: authorize_transaction)

    expect(authorize_transaction.reload.status).to eq('reversed')
  end
end
