module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Bogus
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def acknowledge
            true
          end
        end
      end
    end
  end
end
