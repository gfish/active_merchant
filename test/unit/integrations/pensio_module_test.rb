require 'test_helper'

class PensioModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of Pensio::Notification, Pensio.notification('name=cody')
  end
end 
