# frozen_string_literal: true

class Transaction < ApplicationRecord
  enum status: { approved: 'approved', reversed: 'reversed', refunded: 'refunded', error: 'error' }
  belongs_to :merchant
  belongs_to :reference_transaction,
             class_name: 'Transaction',
             optional: true

  has_many :referenced_transactions,
           class_name: 'Transaction',
           foreign_key: 'reference_transaction_id',
           dependent: :restrict_with_error,
           inverse_of: :reference_transaction

  validates :uuid, :customer_email, presence: true
  validates :uuid, uniqueness: true
  validates :customer_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :approved_charges, -> { where(type: 'ChargeTransaction', status: 'approved') }

  before_create :set_initial_status

  private

  def set_initial_status
    self.status ||= if reference_transaction.present? &&
                       !(reference_transaction.approved? || reference_transaction.refunded?)
                      :error
                    else
                      default_status
                    end
  end

  def reference_transaction_valid?
    reference_transaction.present? && reference_transaction.is_a?(reference_transaction_type)
  end

  def reference_transaction_required
    return if reference_transaction_valid?

    errors.add(:reference_transaction, "must be present and of type #{reference_transaction_type}")
  end

  def default_status
    :approved
  end
end
