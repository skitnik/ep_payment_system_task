# frozen_string_literal: true

class User < ApplicationRecord
  enum status: { inactive: 0, active: 1 }

  validates :name, :status, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
