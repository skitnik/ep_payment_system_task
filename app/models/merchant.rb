# frozen_string_literal: true

class Merchant < User
  has_many :transactions, dependent: :restrict_with_error

  def total_transaction_sum
    transactions.approved_charges.sum(:amount)
  end
end
