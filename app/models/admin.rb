# frozen_string_literal: true

class Admin < User
  after_initialize :set_role, if: :new_record?

  private

  def set_role
    self.role = :admin
  end
end
