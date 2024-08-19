# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'MyString' }
    email { 'MyString' }
    status { 1 }
    total_transaction_sum { '9.99' }
    description { 'MyText' }
  end
end
