# frozen_string_literal: true

class ReversalTransaction < Transaction
  validate :reference_transaction_required
  validate :amount_zero_or_nil_for_reverse

  before_create :reverse_charge_transaction

  private

  def reference_transaction_required
    return if reference_transaction.present? && reference_transaction.is_a?(AuthorizeTransaction)

    errors.add(:reference_transaction, 'must be present and of type AuthorizeTransaction')
  end

  def amount_zero_or_nil_for_reverse
    return if amount.present? && amount.zero?

    errors.add(:amount, 'must be 0 or nil for reversal transactions')
  end

  def reverse_charge_transaction
    return unless approved?

    reference_transaction.update(status: :reversed)
  end
end
