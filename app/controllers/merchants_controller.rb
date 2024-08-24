# frozen_string_literal: true

class MerchantsController < ApplicationController
  before_action :require_login
  before_action :redirect_to_transactions, unless: :session_user_admin?
  before_action :set_merchant, only: %i[show edit update destroy]

  def index
    @merchants = Merchant.order(created_at: 'desc').paginate(page: params[:page], per_page: 5)
  end

  def show
    @transactions = @merchant.transactions.order(created_at: 'desc').paginate(page: params[:page], per_page: 5)
  end

  def edit; end

  def update
    if @merchant.update(merchant_params)
      redirect_to merchants_path, notice: 'Merchant updated successfully.'
    else
      flash.now[:alert] = 'There were problems updating the merchant.'
      render :edit
    end
  end

  def destroy
    if @merchant.destroy
      redirect_to merchants_path, notice: 'Merchant was successfully destroyed.'
    else
      redirect_to merchants_path, alert: @merchant.errors.full_messages
    end
  end

  private

  def redirect_to_transactions
    flash[:alert] = 'Admin permissions required.'

    redirect_to transactions_path
  end

  def set_merchant
    @merchant = Merchant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to merchants_path, alert: 'Merchant not found.'
  end

  def merchant_params
    params.require(:merchant).permit(:name, :email, :status, :description)
  end
end
