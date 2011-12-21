require File.dirname(__FILE__) + '/epay/helper.rb'
require File.dirname(__FILE__) + '/epay/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Epay 
       
        mattr_accessor :service_url
        self.service_url = 'https://relay.ditonlinebetalingssystem.dk/relay/v2/relay.cgi/'

        def self.notification(post)
          Notification.new(post)
        end  
      end
    end
  end
end
