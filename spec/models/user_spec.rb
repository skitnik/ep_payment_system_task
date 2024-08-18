# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:status) }
  it { should allow_value('email@domain.com').for(:email) }
  it { should_not allow_value('invalid_email').for(:email) }

  describe 'email uniqueness' do
    before { create(:merchant) }

    it { should validate_uniqueness_of(:email) }
  end
end
