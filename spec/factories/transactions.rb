# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    amount { 100.0 }
    customer_email { Faker::Internet.unique.email }
    customer_phone { Faker::PhoneNumber.phone_number }
    association :merchant, factory: :merchant

    factory :authorize_transaction, class: 'AuthorizeTransaction' do
      type { 'AuthorizeTransaction' }
    end

    factory :charge_transaction, class: 'ChargeTransaction' do
      type { 'ChargeTransaction' }
      reference_transaction { association :authorize_transaction, merchant: }
    end

    factory :refund_transaction, class: 'RefundTransaction' do
      type { 'RefundTransaction' }
    end

    factory :reversal_transaction, class: 'ReversalTransaction' do
      amount { 0 }
      type { 'ReversalTransaction' }
    end
  end
end
