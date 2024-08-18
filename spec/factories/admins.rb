# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    name { 'Admin Name' }
    description { 'Admin Description' }
    email { 'admin@example.com' }
    role { :admin }
    status { :active }
  end
end
