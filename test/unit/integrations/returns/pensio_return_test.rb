require 'test_helper'

class PensioReturnTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @pensio = Pensio::Return.new(http_raw_data)
    @pensio_error = Pensio::Return.new(http_raw_data_failed)
  end

  def test_return_accessors
    assert @pensio.success?
    assert_equal "123", @pensio.notification.item_id
    assert_equal nil, @pensio.notification.message
  end

  def test_return_accessors_error
    assert_equal false, @pensio_error.success?
    assert_equal "123", @pensio_error.notification.item_id
    assert_equal "This is an error msg", @pensio_error.notification.message
    assert_equal "This is an error msg", @pensio_error.params['error_message']
  end

  private
  def http_raw_data
    "status=succeeded&shop_orderid=123&transaction_id=342&amount=24.23&currency=208&type=payment&payment_status=preauth&masked_credit_card=411111******1234&blacklist_token=asdlkfj234kljadflj2fasd&credit_card_token=klj234lkj23klj234ljk23lkj34&nature=CreditCard&require_capture=true"
  end  

  def http_raw_data_failed
    "status=failed&shop_orderid=123&transaction_id=342&amount=24.23&currency=208&type=payment&payment_status=preauth&masked_credit_card=411111******1234&blacklist_token=asdlkfj234kljadflj2fasd&credit_card_token=klj234lkj23klj234ljk23lkj34&nature=CreditCard&require_capture=true&error_message=This is an error msg"
  end  
end
