# frozen_string_literal: true

Rails.application.routes.draw do
  get 'home/index'

  namespace :api do
    post 'login', to: 'authentication#create'
    resources :payments, only: [:create]
  end
end
