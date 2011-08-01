require 'test_helper'

class PensioNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @pensio = Pensio::Notification.new(http_raw_data, :ip => '77.66.40.133')
  end

  def test_accessors
    assert @pensio.complete?
    assert_equal "succeeded", @pensio.status
    assert_equal "342", @pensio.transaction_id
    assert_equal "123", @pensio.item_id
    assert_equal 24.23, @pensio.gross
    assert_equal 2423, @pensio.gross_cents
    assert_equal "SEK", @pensio.currency
    assert_equal "klj234lkj23klj234ljk23lkj34", @pensio.credit_card_token
    assert_equal true, @pensio.test?
  end

  def test_compositions
    assert_equal Money.new(2423, 'SEK'), @pensio.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement
    assert @pensio.acknowledge
  end

  def test_accessors

    @pensio_e = Pensio::Notification.new(http_raw_data_failed, :ip => '77.66.40.133')
    assert_equal false, @pensio_e.complete?
    assert_equal "failed", @pensio_e.status
    assert_equal "342", @pensio_e.transaction_id
    assert_equal "123", @pensio_e.item_id
    assert_equal 24.23, @pensio_e.gross
    assert_equal 2423, @pensio_e.gross_cents
    assert_equal "SEK", @pensio_e.currency
    assert_equal nil, @pensio_e.credit_card_token
    assert_equal "This is an error msg", @pensio_e.error_message
  end

  def test_correct_ip
    ActiveMerchant::Billing::Base.integration_mode = :somemode
    @pensio = Pensio::Notification.new(http_raw_data, :ip => '77.66.40.133')
    assert_equal true, @pensio.acknowledge
    ActiveMerchant::Billing::Base.integration_mode = :test
  end

  def test_wrong_ip
    ActiveMerchant::Billing::Base.integration_mode = :somemode
    @pensio = Pensio::Notification.new(http_raw_data, :ip => '234.234.234.234')
    assert_equal false, @pensio.acknowledge
    ActiveMerchant::Billing::Base.integration_mode = :test

  end

  def test_respond_to_acknowledge
    assert @pensio.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    "status=succeeded&shop_orderid=123&transaction_id=342&amount=24.23&currency=752&type=payment&payment_status=preauth&masked_credit_card=411111******1234&blacklist_token=asdlkfj234kljadflj2fasd&credit_card_token=klj234lkj23klj234ljk23lkj34&nature=CreditCard&require_capture=true"
  end  

  def http_raw_data_failed
    "status=failed&shop_orderid=123&transaction_id=342&amount=24.23&currency=752&type=payment&payment_status=preauth&masked_credit_card=411111******1234&blacklist_token=asdlkfj234kljadflj2fasd&nature=CreditCard&require_capture=true&error_message=This is an error msg"
  end  
end
