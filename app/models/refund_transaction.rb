# frozen_string_literal: true

class RefundTransaction < Transaction
  validates :amount, numericality: { greater_than: 0 }
  validate :reference_transaction_required

  before_create :process_refund

  private

  def reference_transaction_required
    return if reference_transaction.present? && reference_transaction.is_a?(ChargeTransaction)

    errors.add(:reference_transaction, 'must be present and of type ChargeTransaction')
  end

  def process_refund
    return unless approved?

    reference_transaction.update(status: :refunded)
  end
end
