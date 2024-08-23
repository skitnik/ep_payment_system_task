# frozen_string_literal: true

class JwtToken < ApplicationRecord
  belongs_to :user
end
