# frozen_string_literal: true

module Api
  class PaymentsController < Api::BaseController
    before_action :authenticate_user

    def create
      service = PaymentTransactionService.new(params: payment_params, user: @current_user)
      result = service.create_transaction

      if result[:success]
        respond_with_result({ status: "Payment transaction ##{result[:transaction][:id]} created" }, status: :created)
      else
        respond_with_result({ error: error_message(result[:error]) }, status: :unprocessable_entity)
      end
    end

    private

    def payment_params
      @payment_params ||= if request.format.xml?
                            extract_xml_params(request.body.read, permitted_params)
                          else
                            params.require(:payment).permit(permitted_params)
                          end
    end

    def permitted_params
      %i[amount customer_email customer_phone transaction_type reference_transaction_id]
    end

    def authenticate_user
      return if @current_user.active? && @current_user.is_a?(Merchant)

      respond_with_result({ error: 'Unauthorized' }, status: :unauthorized)
    end

    def error_message(error)
      if error.respond_to?(:full_messages)
        error.full_messages.join(', ')
      else
        "An error occurred: #{error}"
      end
    end

    def respond_root_element
      'payment'
    end
  end
end
