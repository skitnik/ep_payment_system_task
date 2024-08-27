# frozen_string_literal: true

class RefundTransaction < Transaction
  validates :amount, numericality: { greater_than: 0 }
  validate :reference_transaction_required

  before_create :process_refund

  private

  def reference_transaction_type
    ChargeTransaction
  end

  def additional_error_conditions
    already_refunded_transaction?
  end

  def already_refunded_transaction?
    reference_transaction.present? &&
      reference_transaction.is_a?(ChargeTransaction) &&
      reference_transaction.refunded?
  end

  def process_refund
    return unless approved?

    reference_transaction.update(status: :refunded)
  end
end
