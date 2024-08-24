# frozen_string_literal: true

Rails.application.routes.draw do
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :merchants, except: [:new]
  resources :transactions, only: %i[index show]

  namespace :api do
    post 'login', to: 'authentication#create'
    resources :payments, only: [:create]
  end

  root 'sessions#new'
end
