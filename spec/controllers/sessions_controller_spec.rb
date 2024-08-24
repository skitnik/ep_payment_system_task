# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:admin) }
  let(:inactive_user) { create(:merchant, status: :inactive, email: 'inactive@example.com') }

  describe 'GET #new' do
    context 'when no user is logged in' do
      it 'renders the login form' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'when a user is already logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'redirects to the appropriate path based on user role' do
        get :new
        if user.is_a?(Admin)
          expect(response).to redirect_to(merchants_path)
        else
          expect(response).to redirect_to(transactions_path)
        end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs the user in and redirects based on user role' do
        post :create, params: { session: { email: user.email, password: 'password' } }
        expect(session[:user_id]).to eq(user.id)
        if user.is_a?(Admin)
          expect(response).to redirect_to(merchants_path)
        else
          expect(response).to redirect_to(transactions_path)
        end
      end
    end

    context 'with invalid credentials' do
      it 're-renders the login form with an alert' do
        post :create, params: { session: { email: user.email, password: 'wrongpassword' } }
        expect(response).to render_template(:new)
        expect(flash.now[:alert])
          .to eq('The email or password you entered is incorrect, or your account may be inactive.')
      end

      it 're-renders the login form with an alert if the user is inactive' do
        post :create, params: { session: { email: inactive_user.email, password: 'password123' } }
        expect(response).to render_template(:new)
        expect(flash.now[:alert])
          .to eq('The email or password you entered is incorrect, or your account may be inactive.')
      end

      it 're-renders the login form with an alert if the email does not exist' do
        post :create, params: { session: { email: 'nonexistent@example.com', password: 'password123' } }
        expect(response).to render_template(:new)
        expect(flash.now[:alert])
          .to eq('The email or password you entered is incorrect, or your account may be inactive.')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      session[:user_id] = user.id
    end

    it 'logs the user out and redirects to the login page' do
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq('Logged out successfully.')
    end
  end
end
