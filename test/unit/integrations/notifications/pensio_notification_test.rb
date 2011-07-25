require 'test_helper'

class PensioNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @pensio = Pensio::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @pensio.complete?
    assert_equal "succeeded", @pensio.status
    assert_equal "342", @pensio.transaction_id
    assert_equal "123", @pensio.item_id
    assert_equal "24.23", @pensio.gross
    assert_equal "DKK", @pensio.currency
  end

  def test_compositions
    assert_equal Money.new(2423, 'DKK'), @pensio.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @pensio.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    "status=succeeded&shop_orderid=123&transaction_id=342&amount=24.23&currency=208&type=payment&payment_status=preauth&masked_credit_card=411111******1234&blacklist_token=asdlkfj234kljadflj2fasd&credit_card_token=klj234lkj23klj234ljk23lkj34&nature=CreditCard&require_capture=true"
  end  
end
