# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe ImportUserService, type: :service do
  let(:valid_csv_path) { Rails.root.join('spec/fixtures/files/valid_users.csv') }
  let(:invalid_csv_path) { Rails.root.join('spec/fixtures/files/invalid_users.csv') }

  before do
    Admin.destroy_all
    Merchant.destroy_all
  end

  describe '#call' do
    context 'with a valid CSV file' do
      it 'imports users successfully' do
        service = ImportUserService.new(valid_csv_path)

        expect { service.call }.to change { Admin.count }.by(1)
                               .and change { Merchant.count }.by(2)
      end
    end

    context 'with an invalid CSV file' do
      it 'logs an invalid user type error' do
        service = ImportUserService.new(invalid_csv_path)
        logger = Rails.logger

        expect(logger).to receive(:warn).with(/Invalid user type/).twice

        service.call
      end
    end

    context 'with a missing file' do
      it 'raises an error' do
        service = ImportUserService.new(Rails.root.join('spec/fixtures/files/missing.csv'))

        expect { service.call }.to raise_error(RuntimeError, /File not found/)
      end
    end
  end
end
