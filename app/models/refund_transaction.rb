# frozen_string_literal: true

class RefundTransaction < Transaction
  validates :amount, numericality: { greater_than: 0 }
  validate :reference_transaction_required

  before_create :process_refund

  private

  def reference_transaction_type
    ChargeTransaction
  end

  def process_refund
    return unless approved?

    reference_transaction.update(status: :refunded)
  end
end
