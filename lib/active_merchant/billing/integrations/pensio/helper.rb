module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Pensio
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          #Required parameters
          mapping :account, 'terminal'
          mapping :amount, 'amount'
          mapping :currency, 'currency'
        
          mapping :order, 'shop_orderid'

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
            :username => 'customer_info[username]',
            :email      => 'customer_info[email]',
            :phone      => 'customer_info[customer_phone]',
            :bank_name  => 'customer_info[bank_name]',
            :bank_phone => 'customer_info[bank_phone]'

          mapping :billing, 
            :city       => 'customer_info[billing_city]',
            :region     => 'customer_info[billing_region]',
            :address    => 'customer_info[billing_address]',
            :first_name => 'customer_info[billing_firstname]',
            :last_name  => 'customer_info[billing_lastname]',
            :zip        => 'customer_info[billing_postal]',
            :country    => 'customer_info[billing_country]'

          mapping :shipping, 
            :city       => 'customer_info[shipping_city]',
            :region     => 'customer_info[shipping_region]',
            :address    => 'customer_info[shipping_address]',
            :first_name => 'customer_info[shipping_firstname]',
            :last_name  => 'customer_info[shipping_lastname]',
            :zip        => 'customer_info[shipping_postal]',
            :country    => 'customer_info[shipping_country]'

          
        end
      end
    end
  end
end
