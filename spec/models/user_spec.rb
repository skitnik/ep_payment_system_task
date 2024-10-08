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

  describe 'password' do
    let(:user) { build(:merchant) }

    it 'is not accessible as plain text' do
      expect(user.password).not_to eq(user.password_digest)
    end

    it 'has a password_digest after saving' do
      user.save
      expect(user.password_digest).not_to be_nil
    end

    it 'authenticates with correct password' do
      user.save
      expect(User.find_by(email: user.email).authenticate(user.password)).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      user.save
      expect(User.find_by(email: user.email).authenticate('wrong_password')).to be_falsey
    end
  end

  context 'when type is valid' do
    it 'is valid with an allowed user type' do
      User::ALLOWED_USER_TYPES.each do |user_type|
        user = build(:user, type: user_type)
        expect(user).to be_valid
      end
    end
  end

  context 'when type is invalid' do
    it 'is not valid with an invalid user type' do
      user = build(:user, type: 'InvalidUserType')
      expect(user).not_to be_valid
      expect(user.errors[:type])
        .to include("must be one of the following: #{User::ALLOWED_USER_TYPES.join(', ')}")
    end
  end
end
