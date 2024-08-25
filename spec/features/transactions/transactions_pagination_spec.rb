# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Transactions Pagination', type: :feature do
  let!(:merchant) { create(:merchant) }
  let!(:transactions) { create_list(:transaction, 15, merchant:) }

  scenario 'Transactions are paginated' do
    login_as(merchant)
    visit transactions_path

    expect(page).to have_selector('table tbody tr', count: 10)
    expect(page).to have_content('Next')

    click_link 'Next'

    expect(page).to have_selector('table tbody tr', count: 5)
  end
end
