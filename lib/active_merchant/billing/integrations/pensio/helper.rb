module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Pensio
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          def initialize(order, account, options = {})
            super
            @secret = options.delete(:secret)
            add_field(mappings[:terminal], options[:terminal])
          end

          #Required parameters
          mapping :account, 'terminal'
          mapping :amount, 'amount'
          mapping :currency, 'currency'
        
          mapping :item_id, 'shop_orderid'

          #Optional parameters
          mapping :payment_type, 'type'
          mapping :language, 'language'
          mapping :transaction_info, 'transaction_info'

          
          
          #Optional additional payment parameters:
          #A secondary payment is only possible with credit card payments, and when not using 3D-Secure.
          
          mapping :secondary_account, 'secondary_terminal'
          mapping :secondary_shop_orderid, 'secondary_shop_orderid'
          mapping :secondary_amount, 'secondary_amount'
          mapping :secondary_currency, 'secondary_currency'
          mapping :secondary_transaction_info, 'secondary_transaction_info'
          mapping :secondary_type, 'secondary_type'
          mapping :cc_token, 'ccToken'
          mapping :credential2, 'customer_info[checksum]'


          #mandatory fraud detection parameters
          #Only mandatory if fraud detection is enabled on the terminal

          mapping :customer,
            :username   => 'customer_info[username]',
            :email      => 'customer_info[email]',
            :phone      => 'customer_info[customer_phone]',
            :bank_name  => 'customer_info[bank_name]',
            :bank_phone => 'customer_info[bank_phone]'

          mapping :billing_address, 
            :city       => 'customer_info[billing_city]',
            :region     => 'customer_info[billing_region]',
            :address    => 'customer_info[billing_address]',
            :first_name => 'customer_info[billing_firstname]',
            :last_name  => 'customer_info[billing_lastname]',
            :zip        => 'customer_info[billing_postal]',
            :country    => 'customer_info[billing_country]'

          mapping :shipping_address, 
            :city       => 'customer_info[shipping_city]',
            :region     => 'customer_info[shipping_region]',
            :address    => 'customer_info[shipping_address]',
            :first_name => 'customer_info[shipping_firstname]',
            :last_name  => 'customer_info[shipping_lastname]',
            :zip        => 'customer_info[shipping_postal]',
            :country    => 'customer_info[shipping_country]'

          def form_field
            super
            add_field(mappings[:credential2], generate_md5_key) if generate_md5_key
            @fields
          end

          def amount=(money)
            cents = money.respond_to?(:cents) ? money.cents : money
            if money.is_a?(String) or cents.to_i <= 0
              raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents.'
            end
            add_field(mappings[:amount], sprintf("%.2f", cents.to_f/100))
          end

          def currency=(currency)
            if currency
              ActiveMerchant::Billing::PensioGateway.currency_codes.invert[currency.to_s].to_s
            else
              ActiveMerchant::Billing::PensioGateway.default_currency
            end
          end

          def generate_md5_key
            if generate_md5_string
              Digest::MD5.hexdigest(generate_md5_string)
            end
          end

          def optional_fraud_detection_fields
            %w(email username customer_phone bank_name bank_phone billing_firstname billing_lastname billing_address shipping_firstname shipping_lastname shipping_address shipping_city shipping_region shipping_postal shipping_country).inject({}) do |result, str|
              result["customer_info[#{str}]"] = str
              result
            end
          end

          def required_fraud_detection_fields
            %w(billing_city billing_region billing_postal billing_country).inject({}) do |result, str|
              result["customer_info[#{str}]"] = str
              result
            end
          end

          def generate_md5_string
            if @secret.present? && required_fraud_detection_fields.all?{|ci_field,field| ci_field == options.keys.maps{|k| k.to_s}}
              hash = required_fraud_detection_fields.merge(optional_fraud_detection_fields).inject({}) do |result, (ci_field,field)|
                result[field] = options[ci_field.to_sym] if options[ci_field.to_sym]
                result
              end.merge("secret" => @secret)

              hash.sort{|a,b| a[0] <=> b[0]}.map{|fv| "#{fv[0]}=#{fv[1]}"}.join(",")
            end
          end
        end
      end
    end
  end
end
