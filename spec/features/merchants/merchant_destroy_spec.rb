# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Merchant Destroy', type: :feature do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant) }

  scenario 'Admin deletes a merchant' do
    login_as(admin)
    visit merchants_path

    page.driver.submit :delete, merchant_path(merchant), {}

    expect(page).to have_current_path(merchants_path)
    expect(page).to have_content('Merchant was successfully destroyed.')
    expect(page).not_to have_content(merchant.name)
  end

  scenario 'Non-admin cannot access the merchants index page or delete a merchant' do
    non_admin_merchant = create(:merchant, email: 'nonadmin@email.com')
    login_as(non_admin_merchant)

    visit merchants_path

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content('Admin permissions required.')
  end
end
