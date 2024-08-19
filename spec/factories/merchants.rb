# frozen_string_literal: true

FactoryBot.define do
  factory :merchant, class: 'Merchant' do
    name { 'Merchant Name' }
    description { 'Merchant Description' }
    email { 'merchant@example.com' }
    status { :active }
  end
end
