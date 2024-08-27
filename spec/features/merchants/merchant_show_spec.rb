# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Merchant Show', type: :feature do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant) }
  let!(:other_merchant) { create(:merchant) }
  let!(:transaction) { create(:authorize_transaction, merchant:) }

  scenario 'Admin views merchant details' do
    login_as(admin)
    visit merchant_path(merchant)

    expect(page).to have_content(merchant.name)
    expect(page).to have_content(merchant.email)
    expect(page).to have_content(merchant.description)
    expect(page).to have_content(merchant.status.capitalize)
    expect(page).to have_content('Transactions')
    expect(page).to have_content(transaction.uuid)
  end

  scenario 'Non-admin cannot view merchant details' do
    login_as(other_merchant)
    visit merchant_path(merchant)

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content('Admin permissions required.')
  end
end
