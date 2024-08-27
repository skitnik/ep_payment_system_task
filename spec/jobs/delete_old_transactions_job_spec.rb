# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteOldTransactionsJob, type: :job do
  let!(:old_authorize_transaction) { create(:authorize_transaction, created_at: 2.hours.ago) }
  let!(:charge_transaction) do
    create(:charge_transaction, created_at: 1.hour.ago, reference_transaction: old_authorize_transaction)
  end
  let!(:recent_transaction) { create(:authorize_transaction, created_at: 30.minutes.ago) }
  let!(:old_error_transaction) { create(:authorize_transaction, created_at: 2.hours.ago, status: 'error') }

  let(:log_file) { Rails.root.join('log/cron.log') }

  before do
    File.truncate(log_file, 0) if File.exist?(log_file)
  end

  it 'deletes old transactions that are not referenced' do
    expect { described_class.perform_now }
      .to change { Transaction.where(id: old_error_transaction.id).exists? }.from(true).to(false)

    log_contents = File.read(log_file)
    expect(log_contents).to include("Destroying transaction ##{old_error_transaction.id} " \
                                    "created at #{old_error_transaction.created_at}")
  end

  it 'does not delete transactions with references' do
    expect { described_class.perform_now }
      .not_to(change { Transaction.where(id: old_authorize_transaction.id).exists? })

    log_contents = File.read(log_file)
    expect(log_contents).to include("Skipping transaction ##{old_authorize_transaction.id} " \
                                    "created at #{old_authorize_transaction.created_at} " \
                                    'because it has referenced transactions')
  end

  it 'does not delete recent transactions' do
    expect { described_class.perform_now }
      .not_to(change { Transaction.where(id: recent_transaction.id).exists? })
  end
end
