# frozen_string_literal: true

class ChargeTransaction < Transaction
  validate :reference_transaction_required
  validates :amount, numericality: { greater_than: 0 }
  validate :amount_cannot_exceed_authorize_amount

  private

  def reference_transaction_required
    return if reference_transaction.present? && reference_transaction.is_a?(AuthorizeTransaction)

    errors.add(:reference_transaction, 'must be present and of type AuthorizeTransaction')
  end

  def amount_cannot_exceed_authorize_amount
    return unless amount > reference_transaction.amount

    errors.add(:amount, 'cannot exceed the amount of the AuthorizeTransaction')
  end
end
