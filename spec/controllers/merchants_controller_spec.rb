# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MerchantsController, type: :controller do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant) }

  before do
    def log_in(user)
      session[:user_id] = user.id
    end
  end

  describe 'GET #index' do
    context 'when no user is logged in' do
      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq('You need to log in to access this page.')
      end
    end

    context 'when an admin is logged in' do
      before { log_in(admin) }

      it 'assigns @merchants and renders the index template' do
        get :index
        expect(assigns(:merchants)).to eq([merchant])
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    before { log_in(admin) }

    it 'assigns @merchant and @transactions and renders the show template' do
      get :show, params: { id: merchant.id }
      expect(assigns(:merchant)).to eq(merchant)
      expect(assigns(:transactions)).to eq(merchant.transactions.order(created_at: 'desc')
        .paginate(page: nil, per_page: 5))
      expect(response).to render_template(:show)
    end

    it 'redirects to merchants_path if merchant is not found' do
      get :show, params: { id: 'non-existent-id' }
      expect(response).to redirect_to(merchants_path)
      expect(flash[:alert]).to eq('Merchant not found.')
    end
  end

  describe 'GET #edit' do
    before { log_in(admin) }

    it 'assigns @merchant and renders the edit template' do
      get :edit, params: { id: merchant.id }
      expect(assigns(:merchant)).to eq(merchant)
      expect(response).to render_template(:edit)
    end

    it 'redirects if the user is not an admin' do
      log_in(merchant)
      get :edit, params: { id: merchant.id }
      expect(response).to redirect_to(transactions_path)
      expect(flash[:alert]).to eq('Admin permissions required.')
    end
  end

  describe 'PATCH #update' do
    before { log_in(admin) }

    context 'with valid attributes' do
      it 'updates the merchant and redirects to merchants_path' do
        patch :update, params: { id: merchant.id, merchant: { name: 'Updated Name' } }
        merchant.reload
        expect(merchant.name).to eq('Updated Name')
        expect(response).to redirect_to(merchants_path)
        expect(flash[:notice]).to eq('Merchant updated successfully.')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the merchant and re-renders the edit template' do
        patch :update, params: { id: merchant.id, merchant: { email: '' } }
        expect(merchant.reload.email).not_to eq('')
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to eq('There were problems updating the merchant.')
      end
    end
  end

  describe 'DELETE #destroy' do
    before { log_in(admin) }

    it 'destroys the merchant and redirects to merchants_path' do
      delete :destroy, params: { id: merchant.id }
      expect(Merchant.exists?(merchant.id)).to be_falsey
      expect(response).to redirect_to(merchants_path)
      expect(flash[:notice]).to eq('Merchant was successfully destroyed.')
    end

    it 'does not destroy the merchant and redirects if there are errors' do
      allow_any_instance_of(Merchant).to receive(:destroy).and_return(false)
      delete :destroy, params: { id: merchant.id }
      expect(response).to redirect_to(merchants_path)
      expect(flash[:alert]).to eq(merchant.errors.full_messages)
    end
  end
end
