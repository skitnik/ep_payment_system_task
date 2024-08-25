# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Merchants Index', type: :feature do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant, name: 'Merchant One') }
  let!(:merchant2) { create(:merchant, name: 'Merchant Two', email: 'merchant2@email.com') }

  scenario 'Admin sees all merchants' do
    login_as(admin)
    visit merchants_path

    expect(page).to have_content('Merchant One')
    expect(page).to have_content('Merchant Two')
  end

  scenario 'Non-admin cannot access merchants index' do
    login_as(merchant)
    visit merchants_path

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content('Admin permissions required.')
  end
end
