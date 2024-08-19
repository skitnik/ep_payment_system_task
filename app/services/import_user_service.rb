# frozen_string_literal: true

require 'csv'

class ImportUserService
  def initialize(file_path)
    @file_path = file_path
  end

  def call
    raise "File not found: #{@file_path}" unless File.exist?(@file_path)

    CSV.foreach(@file_path, headers: true) do |row|
      import_user(row)
    end

    Rails.logger.info 'Import finished!'
  end

  private

  def import_user(row)
    user_type = find_user_type(row['type'])
    unless user_type
      Rails.logger.warn "Invalid user type #{row['type']} for email #{row['email']}"
      return
    end
    user_type.create!(user_data(row))
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to import user with email #{row['email']}: #{e.record.errors.full_messages.join(', ')}"
  end

  def find_user_type(type)
    if type == 'admin'
      Admin
    elsif type == 'merchant'
      Merchant
    end
  end

  def user_data(row)
    {
      name: row['name'],
      email: row['email'],
      status: row['status'],
      description: row['description']
    }
  end
end
