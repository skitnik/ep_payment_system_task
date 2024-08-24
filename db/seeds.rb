# frozen_string_literal: true

Admin.create!(
  name: 'admin',
  email: 'admin@admin.com',
  password: 'admin',
  status: :active
)

merchant1 = Merchant.create!(
  name: 'Merchant',
  email: 'merchant@merchant.com',
  description: 'Has refunded transaction',
  password: 'merchant',
  status: :active
)

merchant2 = Merchant.create!(
  name: 'Merchant2',
  email: 'merchant2@merchant.com',
  description: 'Has reversal transaction',
  password: 'merchant2',
  status: :active
)

Merchant.create!(
  name: 'No transactions merchant',
  email: 'merchant3@merchant.com',
  description: 'Merchant with no transcations',
  password: 'merchant3',
  status: :active
)

Merchant.create!(
  name: 'Inactive merchant',
  email: 'merchant4@merchant.com',
  description: 'Inactive merchant',
  password: 'merchant4',
  status: :inactive
)

authorize_transaction1 = AuthorizeTransaction.create!(
  amount: 100.00,
  customer_email: 'customer@email.com',
  customer_phone: '1234567890',
  merchant: merchant1
)

authorize_transaction2 = AuthorizeTransaction.create!(
  amount: 200.00,
  customer_email: 'customer2@email.com',
  customer_phone: '1234567890',
  merchant: merchant2
)

ChargeTransaction.create!(
  amount: 20.00,
  customer_email: 'customer@email.com',
  customer_phone: '1234567890',
  merchant: merchant1,
  reference_transaction: authorize_transaction1
)

charge_transaction2 = ChargeTransaction.create!(
  amount: 20.00,
  customer_email: 'customer@email.com',
  customer_phone: '1234567890',
  merchant: merchant1,
  reference_transaction: authorize_transaction1
)

RefundTransaction.create!(
  amount: 20.00,
  customer_email: 'customer@email.com',
  customer_phone: '1234567890',
  merchant: merchant1,
  reference_transaction: charge_transaction2
)

ReversalTransaction.create!(
  customer_email: 'customer@email.com',
  customer_phone: '1234567890',
  merchant: merchant2,
  reference_transaction: authorize_transaction2
)
