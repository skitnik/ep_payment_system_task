# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MerchantsController, type: :controller do
  let!(:admin) { create(:admin) }
  let!(:merchant) { create(:merchant) }
  let(:valid_attributes) { { name: 'Updated Name' } }
  let(:invalid_attributes) { { email: '' } }

  before do
    def log_in(user)
      session[:user_id] = user.id
    end

    def log_out
      session.delete(:user_id)
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

    context 'when the merchant is found' do
      it 'assigns @merchant and @transactions and renders the show template' do
        get :show, params: { id: merchant.id }
        expect(assigns(:merchant)).to eq(merchant)
        expect(assigns(:transactions)).to eq(merchant.transactions.order(created_at: :desc).paginate(page: nil,
                                                                                                     per_page: 5))
        expect(response).to render_template(:show)
      end
    end

    context 'when the merchant is not found' do
      it 'redirects to merchants_path with an alert' do
        get :show, params: { id: 'non-existent-id' }
        expect(response).to redirect_to(merchants_path)
        expect(flash[:alert]).to eq('Merchant not found.')
      end
    end
  end

  describe 'GET #edit' do
    context 'when an admin is logged in' do
      before { log_in(admin) }

      it 'assigns @merchant and renders the edit template' do
        get :edit, params: { id: merchant.id }
        expect(assigns(:merchant)).to eq(merchant)
        expect(response).to render_template(:edit)
      end
    end

    context 'when a non-admin user is logged in' do
      before { log_in(merchant) }

      it 'redirects to transactions_path with an alert' do
        get :edit, params: { id: merchant.id }
        expect(response).to redirect_to(transactions_path)
        expect(flash[:alert]).to eq('Admin permissions required.')
      end
    end
  end

  describe 'PATCH #update' do
    before { log_in(admin) }

    context 'with valid attributes' do
      it 'updates the merchant and redirects to merchants_path' do
        patch :update, params: { id: merchant.id, merchant: valid_attributes }
        merchant.reload
        expect(merchant.name).to eq('Updated Name')
        expect(response).to redirect_to(merchants_path)
        expect(flash[:notice]).to eq('Merchant updated successfully.')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the merchant and re-renders the edit template' do
        patch :update, params: { id: merchant.id, merchant: invalid_attributes }
        expect(merchant.reload.email).not_to eq('')
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to eq('There were problems updating the merchant.')
      end
    end
  end

  describe 'DELETE #destroy' do
    before { log_in(admin) }

    context 'when successful' do
      it 'destroys the merchant and redirects to merchants_path' do
        delete :destroy, params: { id: merchant.id }
        expect(Merchant.exists?(merchant.id)).to be_falsey
        expect(response).to redirect_to(merchants_path)
        expect(flash[:notice]).to eq('Merchant was successfully destroyed.')
      end
    end

    context 'when there are errors' do
      before do
        allow_any_instance_of(Merchant).to receive(:destroy).and_return(false)
      end

      it 'does not destroy the merchant and redirects with an alert' do
        delete :destroy, params: { id: merchant.id }
        expect(response).to redirect_to(merchants_path)
      end
    end
  end
end
