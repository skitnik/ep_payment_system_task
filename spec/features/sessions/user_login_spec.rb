# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User Login', type: :feature do
  let!(:active_user) { create(:merchant, email: 'active_user@example.com') }
  let!(:active_admin) { create(:admin, email: 'active_admin@example.com') }
  let!(:inactive_user) { create(:merchant, email: 'inactive_user@example.com', status: :inactive) }

  scenario 'User logs in with valid credentials' do
    login_as(active_user)

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content('Transactions')
  end

  scenario 'Admin logs in with valid credentials' do
    login_as(active_admin)

    expect(page).to have_current_path(merchants_path)
    expect(page).to have_content('Merchants')
  end

  scenario 'User logs in with invalid credentials' do
    login_as(Merchant.new(email: 'wrong@example.com'))

    expect(page).to have_content('The email or password you entered is incorrect, or your account may be inactive.')
  end

  scenario 'Inactive user tries to log in' do
    login_as(inactive_user)

    expect(page).to have_content('The email or password you entered is incorrect, or your account may be inactive.')
  end

  scenario 'User is redirected if already logged in' do
    login_as(active_user)

    visit login_path

    expect(page).to have_current_path(transactions_path)
  end

  scenario 'User logs out successfully' do
    login_as(active_user)

    click_link 'Logout'

    expect(page).to have_current_path(login_path)
    expect(page).to have_content('Login')
  end
end
