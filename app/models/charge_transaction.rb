# frozen_string_literal: true

class ChargeTransaction < Transaction
  validate :reference_transaction_required
  validate :amount_cannot_exceed_authorize_amount, if: -> { reference_transaction_valid? }
  validates :amount, numericality: { greater_than: 0 }

  private

  def reference_transaction_type
    AuthorizeTransaction
  end

  def amount_cannot_exceed_authorize_amount
    return unless amount > reference_transaction.amount

    errors.add(:amount, "cannot exceed the amount of the #{reference_transaction_type}")
  end
end
