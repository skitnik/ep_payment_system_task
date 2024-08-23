# frozen_string_literal: true

class ReversalTransaction < Transaction
  validate :reference_transaction_required
  validate :amount_zero_or_nil_for_reverse

  before_create :reverse_charge_transaction

  private

  def reference_transaction_type
    AuthorizeTransaction
  end

  def amount_zero_or_nil_for_reverse
    return if amount.nil?

    errors.add(:amount, 'must be 0 or none for reversal transactions') unless amount.zero?
  end

  def reverse_charge_transaction
    return unless approved?

    reference_transaction.update(status: :reversed)
  end
end
