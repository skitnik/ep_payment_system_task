# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'User' do
    name { Faker::Company.name }
    password { 'password' }
    description { Faker::Company.catch_phrase }
    email { Faker::Internet.unique.email }
    status { :active }

    factory :admin, class: 'Admin' do
      type { 'Admin' }
    end

    factory :merchant, class: 'Merchant' do
      type { 'Merchant' }
    end
  end
end
