# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Transactions Index', type: :feature do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant, email: 'merchant@email.com') }
  let!(:other_merchant) { create(:merchant, email: 'othermerchant@email.com') }

  let!(:transaction1) { create(:authorize_transaction, merchant:) }
  let!(:transaction2) { create(:authorize_transaction, merchant:) }
  let!(:transaction3) { create(:authorize_transaction, merchant: other_merchant) }

  scenario 'Admin sees all transactions' do
    login_as(admin)
    visit transactions_path

    expect(page).to have_content(transaction1.uuid)
    expect(page).to have_content(transaction2.uuid)
    expect(page).to have_content(transaction3.uuid)
  end

  scenario 'Merchant sees only their transactions' do
    login_as(merchant)
    visit transactions_path

    expect(page).to have_content(transaction1.uuid)
    expect(page).to have_content(transaction2.uuid)
    expect(page).not_to have_content(transaction3.uuid)
  end

  scenario 'Other merchant cannot see the transactions' do
    login_as(other_merchant)
    visit transaction_path(transaction1)

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content('You do not have access to this transaction.')
  end
end
