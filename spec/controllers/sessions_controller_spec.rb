# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:inactive_merchant) { create(:merchant, status: :inactive) }
  let(:valid_params) { { session: { email: admin.email, password: 'password' } } }
  let(:invalid_params) { { session: { email: admin.email, password: 'wrongpassword' } } }
  let(:inactive_params) { { session: { email: inactive_merchant.email, password: 'password123' } } }
  let(:nonexistent_params) { { session: { email: 'nonexistent@example.com', password: 'password123' } } }

  describe 'GET #new' do
    context 'when no user is logged in' do
      it 'renders the login form' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'when a user is already logged in' do
      before { session[:user_id] = admin.id }

      it 'redirects to the appropriate path based on user role' do
        get :new
        expect(response).to redirect_to(admin_redirect_path(admin))
      end
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs the user in and redirects based on user role' do
        post :create, params: valid_params
        expect(session[:user_id]).to eq(admin.id)
        expect(response).to redirect_to(admin_redirect_path(admin))
      end
    end

    context 'with invalid credentials' do
      it 're-renders the login form with an alert for incorrect password' do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(flash.now[:alert])
          .to eq('The email or password you entered is incorrect, or your account may be inactive.')
      end

      it 're-renders the login form with an alert if the user is inactive' do
        post :create, params: inactive_params
        expect(response).to render_template(:new)
        expect(flash.now[:alert])
          .to eq('The email or password you entered is incorrect, or your account may be inactive.')
      end

      it 're-renders the login form with an alert if the email does not exist' do
        post :create, params: nonexistent_params
        expect(response).to render_template(:new)
        expect(flash.now[:alert])
          .to eq('The email or password you entered is incorrect, or your account may be inactive.')
      end
    end
  end

  describe 'DELETE #destroy' do
    before { session[:user_id] = admin.id }

    it 'logs the user out and redirects to the login page' do
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq('Logged out successfully.')
    end
  end

  private

  def admin_redirect_path(user)
    user.is_a?(Admin) ? merchants_path : transactions_path
  end
end
