# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    name { 'Merchant Name' }
    description { 'Merchant Description' }
    email { 'merchant@example.com' }
    role { :merchant }
    status { :active }
  end
end
