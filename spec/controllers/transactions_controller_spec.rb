# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let(:admin) { create(:admin) }
  let(:merchant) { create(:merchant) }
  let(:other_merchant) { create(:merchant, email: 'othermerchant@email.com') }
  let(:transaction) { create(:authorize_transaction, merchant:) }
  let(:other_transaction) { create(:authorize_transaction, merchant: other_merchant) }

  before do
    def log_in(user)
      session[:user_id] = user.id
    end

    def log_out
      session[:user_id] = nil
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

    context 'when a merchant is logged in' do
      before { log_in(merchant) }

      it 'assigns @transactions and renders the index template' do
        get :index
        expect(assigns(:transactions)).to include(transaction)
        expect(response).to render_template(:index)
      end
    end

    context 'when an admin is logged in' do
      before { log_in(admin) }

      it 'assigns all transactions and renders the index template' do
        get :index
        expect(assigns(:transactions)).to include(transaction, other_transaction)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET #show' do
    context 'when no user is logged in' do
      it 'redirects to the login page' do
        get :show, params: { id: transaction.id }
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to eq('You need to log in to access this page.')
      end
    end

    context 'when a merchant is logged in and is authorized' do
      before { log_in(merchant) }

      it 'assigns @transaction and @parent_transaction and renders the show template' do
        get :show, params: { id: transaction.id }
        expect(assigns(:transaction)).to eq(transaction)
        expect(assigns(:parent_transaction)).to eq(transaction.reference_transaction)
        expect(response).to render_template(:show)
      end
    end

    context 'when a merchant is logged in but is not authorized' do
      before { log_in(merchant) }

      it 'redirects to transactions_path with an alert' do
        get :show, params: { id: other_transaction.id }
        expect(response).to redirect_to(transactions_path)
        expect(flash[:alert]).to eq('You do not have access to this transaction.')
      end
    end

    context 'when an admin is logged in' do
      before { log_in(admin) }

      it 'assigns @transaction and @parent_transaction and renders the show template' do
        get :show, params: { id: transaction.id }
        expect(assigns(:transaction)).to eq(transaction)
        expect(assigns(:parent_transaction)).to eq(transaction.reference_transaction)
        expect(response).to render_template(:show)
      end
    end

    context 'when transaction is not found' do
      before { log_in(admin) }

      it 'redirects to transactions_path with an alert' do
        get :show, params: { id: 'non-existent-id' }
        expect(response).to redirect_to(transactions_path)
        expect(flash[:alert]).to eq('Transaction not found.')
      end
    end
  end
end
