require File.dirname(__FILE__) + '/pensio/helper.rb'
require File.dirname(__FILE__) + '/pensio/notification.rb'
require File.dirname(__FILE__) + '/pensio/return.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Pensio 
       
        mattr_accessor :service_url
        self.service_url = 'https://testgateway.pensio.com/eCommerce/API/form/'

        def self.notification(post)
          Notification.new(post)
        end  
      end
    end
  end
end
