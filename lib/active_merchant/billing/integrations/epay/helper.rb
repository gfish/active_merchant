module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Epay
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          def initialize(order, account, options = {})
            super
            @md5secret = options.delete(:credential2)
            @referrer_url = options.delete(:credential3)
            @options = options
          end

          mapping :account, 'merchantnumber'
          mapping :amount, 'amount'
          mapping :order, 'orderid'
          mapping :payment_type, 'paymenttype'
          mapping :group, 'group'

          mapping :notify_url, 'callbackurl'
          mapping :return_url, 'accepturl'
          mapping :decline_url, 'declineurl'

          mapping :subscription, 'subscription'
          mapping :http_accept_url, 'httpaccepturl'
          mapping :instant_callback, 'instantcallback'

          mapping :customer, ''
          mapping :billing_address, ''

          mapping :credential4, 'md5key'
          mapping :currency, 'currency'

          MD5_FIELDS = [
            :currency, :amount, :orderid
          ]

          def service_url
            "https://relay.ditonlinebetalingssystem.dk/relay/v2/relay.cgi/#{@referrer_url}"
          end

          def payment_form_processing_url
            'https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx'
          end

          def form_fields
            add_field(mappings[:currency], find_currency(@options[:currency]))
            add_field(mappings[:credential4], generate_md5_key) if @md5secret
            @fields
          end

          def find_currency(cur)
            cur ||= ActiveMerchant::Billing::EpayGateway.default_currency
            ActiveMerchant::Billing::EpayGateway::CURRENCY_CODES[cur.upcase.to_sym].to_s
          end

          def generate_md5_key
            Digest::MD5.hexdigest(MD5_FIELDS.map {|key| @fields[key.to_s]} * "" + @md5secret)
          end
        end
      end
    end
  end
end
