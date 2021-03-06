module Vpago
  module AcledaMobile
    class PaymentRequestUpdater
      attr_accessor :payment, :error_message

      def initialize(payment, options={})
        @payment = payment
        @options = options
      end

      def call
        checker = payment_status_checker

        if(checker.success?)
          @error_message = nil
          checker_result = {
            status: true,
            description: nil,
            acleda_response: checker.result,
          }
          marker_options = @options.merge(checker_result)

          marker = ::Vpago::PaymentStatusMarker.new(@payment, marker_options)
          marker.call
        else
          @error_message = checker.error_message
          marker_options = @options.merge(status: false, description: @error_message)

          marker = ::Vpago::PaymentStatusMarker.new(@payment, marker_options)
          marker.call
        end
      end

      def payment_status_checker
        trans_status = Vpago::AcledaMobile::TransactionStatus.new(@payment)
        trans_status.call(@options[:payment_token_id]) ##TO DO: remove payment_token_id when check transaction status api ready
        trans_status
      end
    end
  end
end
