# frozen_string_literal: true

class User < ApplicationRecord
  ALLOWED_USER_TYPES = %w[Merchant Admin].freeze
  has_secure_password
  enum status: { inactive: 0, active: 1 }

  validates :name, :status, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :type, inclusion: { in: ALLOWED_USER_TYPES,
                                message: "must be one of the following: #{ALLOWED_USER_TYPES.join(', ')}" }
end
