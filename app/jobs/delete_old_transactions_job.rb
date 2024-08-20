# frozen_string_literal: true

class DeleteOldTransactionsJob < ApplicationJob
  queue_as :default

  def logger
    @logger ||= Logger.new(Rails.root.join('log/cron.log'))
  end

  def perform
    logger.info "Starting DeleteOldTransactionsJob at #{Time.current}"

    Transaction.includes(:referenced_transactions)
               .where('created_at < ?', 1.hour.ago)
               .find_each do |transaction|
      delete_transaction(transaction)
    end

    logger.info "Completed DeleteOldTransactionsJob at #{Time.current}"
  end

  private

  def delete_transaction(transaction)
    if transaction.referenced_transactions.empty?
      logger.info "Destroying transaction ##{transaction.id} created at #{transaction.created_at}"
      transaction.destroy
    else
      logger.info "Skipping transaction ##{transaction.id} " \
            "created at #{transaction.created_at} " \
            'because it has referenced transactions'
    end
  end
end
