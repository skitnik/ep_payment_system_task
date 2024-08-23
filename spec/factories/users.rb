# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'name' }
    email { 'email@example.com' }
    password { 'password' }
    status { 1 }
    total_transaction_sum { '9.99' }
    description { 'description' }
  end
end
