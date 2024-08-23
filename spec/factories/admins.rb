# frozen_string_literal: true

FactoryBot.define do
  factory :admin, class: 'Admin' do
    name { 'Admin Name' }
    password { 'password' }
    description { 'Admin Description' }
    email { 'admin@example.com' }
    status { :active }
  end
end
