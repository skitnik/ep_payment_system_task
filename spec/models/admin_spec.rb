# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, type: :model do
  it 'inherits from User' do
    expect(Merchant.ancestors).to include(User)
  end

  describe 'callbacks' do
    it 'sets the role to admin after initialization' do
      admin = Admin.new
      expect(admin.role).to eq('admin')
    end
  end
end
