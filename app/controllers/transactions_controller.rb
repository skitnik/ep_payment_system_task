# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :require_login
  before_action :set_transaction, only: :show
  before_action :authorize_transaction_access, only: :show

  def index
    data = if session_user_admin?
             Transaction.order(created_at: 'desc')
           else
             @session_user.transactions.order(created_at: 'desc')
           end

    @transactions = data.paginate(page: params[:page], per_page: 10)
  end

  def show
    @parent_transaction = @transaction.reference_transaction
  end

  private

  def set_transaction
    @transaction = Transaction.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to transactions_path, alert: 'Transaction not found.'
  end

  def authorize_transaction_access
    return if session_user_admin? || (@transaction.merchant == @session_user)

    redirect_to transactions_path, alert: 'You do not have access to this transaction.'
  end
end
