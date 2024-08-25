# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Transaction Show', type: :feature do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant) }
  let!(:authorize_transaction) { create(:authorize_transaction, merchant:) }
  let!(:charge_transaction) { create(:charge_transaction, merchant:, reference_transaction: authorize_transaction) }
  let!(:refund_transaction) { create(:refund_transaction, reference_transaction: charge_transaction, merchant:) }

  scenario 'Merchant views transaction details' do
    login_as(merchant)
    visit transaction_path(charge_transaction)

    expect(page).to have_content(charge_transaction.uuid)
    expect(page).to have_content(charge_transaction.type.humanize)
    expect(page).to have_content(charge_transaction.status.humanize)
    expect(page).to have_content(charge_transaction.customer_email)

    expect(page).to have_content(authorize_transaction.uuid)
    expect(page).to have_content(refund_transaction.uuid)
  end

  scenario 'Admin views transaction details' do
    login_as(admin)
    visit transaction_path(charge_transaction)

    expect(page).to have_content(charge_transaction.uuid)
    expect(page).to have_content(charge_transaction.type.humanize)
    expect(page).to have_content(charge_transaction.status.humanize)
    expect(page).to have_content(charge_transaction.customer_email)
  end

  scenario 'Unauthorized user cannot view transaction details' do
    other_merchant = create(:merchant, email: 'othermerchant@email.com')
    login_as(other_merchant)
    visit transaction_path(charge_transaction)

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content('You do not have access to this transaction.')
  end
end
