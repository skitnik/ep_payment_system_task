# frozen_string_literal: true

class PaymentTransactionService
  def initialize(params:, user:)
    @params = params
    @user = user
  end

  def create_transaction
    transaction_class = determine_transaction_class
    return { success: false, error: 'transaction_type is required' } unless transaction_class

    transaction = transaction_class.new(transaction_params)
    if transaction.save
      { success: true, transaction: }
    else
      { success: false, error: transaction.errors }
    end
  end

  private

  def determine_transaction_class
    case @params['transaction_type']
    when 'authorize'
      AuthorizeTransaction
    when 'charge'
      ChargeTransaction
    when 'refund'
      RefundTransaction
    when 'reversal'
      ReversalTransaction
    end
  end

  def transaction_params
    {
      uuid: SecureRandom.uuid,
      amount: @params['amount'],
      customer_email: @params['customer_email'],
      customer_phone: @params['customer_phone'],
      merchant: @user,
      reference_transaction_id: @params['reference_transaction_id']
    }
  end
end
