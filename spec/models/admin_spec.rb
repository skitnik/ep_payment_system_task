# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, type: :model do
  it 'inherits from User' do
    expect(Merchant.ancestors).to include(User)
  end
end
