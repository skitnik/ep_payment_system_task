# frozen_string_literal: true

FactoryBot.define do
  factory :jwt_token do
    association :user
    user { nil }
    token { 'MyString' }
    exp { '2024-08-20 13:01:28' }
  end
end
