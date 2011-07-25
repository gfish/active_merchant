require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Pensio
        class Notification < ActiveMerchant::Billing::Integrations::Notification

          def complete?
            status == "succeeded"
          end 

          def item_id
            params['shop_orderid']
          end

          def transaction_id
            params['transaction_id']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['amount']
          end

          # Was this a test transaction?
          def test?
            params[''] == 'test'
          end

          def error_message
            params['error_message']
          end

          def status
            params['status']
          end

          def currency
            if params['currency']
              ActiveMerchant::Billing::PensioGateway.currency_codes.invert[params['currency'].to_s].to_s
            else
              ActiveMerchant::Billing::PensioGateway.default_currency
            end
          end

          # Provide access to raw fields from Pensio
          %w(transaction_info type payment_status masked_credit_card blacklist_token credit_card_token nature require_capture).each do |attr|
            define_method(attr) do
              params[attr]
            end
          end

          # Provide access to secondary payment callback parameters
          # If a secondary payment was created we also post back all of the following parameters.
          %w(secondary_shop_orderid secondary_transaction_id secondary_amount secondary_currency secondary_transaction_info secondary_type secondary_payment_status).each do |attr|
            define_method(attr) do
              params[attr]
            end
          end

          # Fraud Detection Parameters:
          # If fraud detection is available for the payment we also post back the following parameters.

          %w(fraud_risk_score fraud_explanation).each do |attr|
            define_method(attr) do
              params[attr]
            end
          end


          # Address Verification Parameters
          # If address verification is available for the payment we also post back the following parameters.
          %w(avs_code avs_text).each do |attr|
            define_method(attr) do
              params[attr]
            end
          end

          # Acknowledge the transaction to Pensio. This method has to be called after a new 
          # apc arrives. Pensio will verify that all the information we received are correct and will return a 
          # ok or a fail. 
          # 
          # Example:
          # 
          #   def ipn
          #     notify = PensioNotification.new(request.raw_post)
          #
          #     if notify.acknowledge 
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge      
            payload = raw

            uri = URI.parse(Pensio.notification_confirmation_url)

            request = Net::HTTP::Post.new(uri.path)

            request['Content-Length'] = "#{payload.size}"
            request['User-Agent'] = "Active Merchant -- http://home.leetsoft.com/am"
            request['Content-Type'] = "application/x-www-form-urlencoded" 

            http = Net::HTTP.new(uri.host, uri.port)
            http.verify_mode    = OpenSSL::SSL::VERIFY_NONE unless @ssl_strict
            http.use_ssl        = true

            response = http.request(request, payload)

            # Replace with the appropriate codes
            raise StandardError.new("Faulty Pensio result: #{response.body}") unless ["AUTHORISED", "DECLINED"].include?(response.body)
            response.body == "AUTHORISED"
          end
 private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end
        end
      end
    end
  end
end
