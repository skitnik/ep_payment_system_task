# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizeTransaction, type: :model do
  it 'has a valid factory' do
    expect(build(:authorize_transaction)).to be_valid
  end
end
