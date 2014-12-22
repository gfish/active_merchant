module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Epay
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          def initialize(order, account, options = {})
            @use_payment_window = options.delete(:payment_window) || false

            mappings[:credential4] = 'hash' if @use_payment_window

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
          mapping :subscription, 'subscription'

          mapping :notify_url, 'callbackurl'
          mapping :return_url, 'accepturl'
          mapping :decline_url, 'declineurl'

          mapping :http_accept_url, 'httpaccepturl'
          mapping :instant_callback, 'instantcallback'

          mapping :customer, ''
          mapping :billing_address, ''

          mapping :credential4, 'md5key'
          mapping :currency, 'currency'

          MD5_FIELDS = [
            :currency, :amount, :orderid
          ]
          MD5_FIELDS_WINDOW = [
            :merchantnumber, :currency, :amount, :orderid, :windowid, :mobile, :paymentcollection, :lockpaymentcollection,
            :paymenttype, :language, :encoding, :cssurl, :mobilecssurl, :instantcapture, :splitpayment, :accepturl,
            :cancelurl, :callbackurl, :instantcallback, :ownreceipt, :ordertext, :group, :description, :subscription,
            :subscriptionid, :subscriptionname, :mailreceipt, :googletracker, :backgroundcolor, :opacity, :declinetext,
            :timeout, :invoice
	  ]

          def service_url
            if @use_payment_window
              @referrer_url
            else
              "https://relay.ditonlinebetalingssystem.dk/relay/v2/relay.cgi/#{@referrer_url}"
            end
          end

          def payment_form_processing_url
            if @use_payment_window
              'https://ssl.ditonlinebetalingssystem.dk/integration/ewindow/Default.aspx'
            else
              'https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx'
            end
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
            if @use_payment_window
              Digest::MD5.hexdigest(@fields.select {|key| MD5_FIELDS_WINDOW.map(&:to_s).include? key }.values * "" + @md5secret)
            else
	      Digest::MD5.hexdigest(MD5_FIELDS.map {|key| @fields[key.to_s]} * "" + @md5secret)
            end
          end
        end
      end
    end
  end
end
