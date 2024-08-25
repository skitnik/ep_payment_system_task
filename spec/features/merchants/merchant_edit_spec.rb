# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Merchant Edit', type: :feature do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant) }

  scenario 'Admin edits a merchant' do
    login_as(admin)
    visit edit_merchant_path(merchant)

    fill_in 'Name', with: 'Updated Name'
    fill_in 'Email', with: 'updated_email@example.com'
    fill_in 'Description', with: 'Updated Description'
    select 'Inactive', from: 'Status'
    click_button 'Edit'

    expect(page).to have_current_path(merchants_path)
    expect(page).to have_content('Merchant updated successfully.')
  end

  scenario 'Non-admin cannot edit a merchant' do
    non_admin_merchant = create(:merchant, email: 'nonadmin@email.com')
    login_as(non_admin_merchant)
    visit edit_merchant_path(merchant)

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content('Admin permissions required.')
  end
end
