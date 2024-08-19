# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, type: :model do
  it 'inherits from User' do
    expect(Merchant.ancestors).to include(User)
  end

  describe 'callbacks' do
    it 'sets the type to admin after initialization' do
      admin = build(:admin)
      expect(admin.type).to eq('Admin')
    end
  end
end
