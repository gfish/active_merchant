module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Pensio
        class Return < ActiveMerchant::Billing::Integrations::Return

          def initialize(query_string, options = {})
            super
            @notification = Notification.new(query_string, options)
          end

          def success?
            @notification && @notification.complete?
          end
        end
      end
    end
  end
end
