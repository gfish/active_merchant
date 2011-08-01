require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Pensio
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          self.production_ips = [ '77.66.40.133' ]

          def complete?
            status == "succeeded"
          end 

          def item_id
            params['shop_orderid']
          end

          def transaction_id
            params['transaction_id']
          end
          
          #info
          def received_at
            params['']
          end

          def payer_email
            params['']
          end
         
          def receiver_email
            params['']
          end 

          # The MD5 Hash
          def security_key
            params['']
          end

          # the money amount we received in X.2 decimal.
          def gross
            if params['amount']
              params['amount'].to_f
            end
          end

          # Was this a test transaction?
          def test?
            params['transaction_info'] == ['test']
          end

          def message
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
          %w(transaction_info type payment_status masked_credit_card blacklist_token credit_card_token nature require_capture error_message).each do |attr|
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
            if @options[:ip]
              valid_sender?(@options[:ip])
            end
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
