require 'test_helper'

class EpayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = Epay::Helper.new(
      'order500',
      '1234567',
      :amount => 500,
      :currency => 'DKK',
      :credential2 => '3fjjk32jkl2nk3l2',
      :credential3 => 'http://example.com'
    )
  end
 
  def test_basic_helper_fields
    assert_field 'orderid', 'order500'
    assert_field 'merchantnumber', '1234567'
    assert_field 'amount', '500'
    assert_field 'currency', 'DKK'
    assert_field 'credential2', nil
    assert_field 'credential3', nil
  end

  def test_basic_helper_form_fields
    @helper.http_accept_url = 0
    @helper.instant_callback = 1
    @helper.payment_type = 0
    @helper.subscription = 1
    @helper.notify_url = "http://example.com/callback"
    @helper.return_url = "http://example.com/accepted"
    @helper.decline_url = "http://example.com/declined"

    assert_equal 'order500', @helper.form_fields['orderid']
    assert_equal '208', @helper.form_fields['currency']
    assert_equal '500', @helper.form_fields['amount']
    assert_equal '1234567', @helper.form_fields['merchantnumber']
    assert_equal '0', @helper.form_fields['paymenttype']
    assert_equal '6845be2847be9f920cad101fb0367e1b', @helper.form_fields['md5key']
    assert_equal '1', @helper.form_fields['subscription']
    assert_equal 'http://example.com/callback', @helper.form_fields['callbackurl']
    assert_equal 'http://example.com/accepted', @helper.form_fields['accepturl']
    assert_equal 'http://example.com/declined', @helper.form_fields['declineurl']
    assert_equal 'https://relay.ditonlinebetalingssystem.dk/relay/v2/relay.cgi/http://example.com', @helper.service_url
    assert_equal 'https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx', @helper.payment_form_processing_url
  end
end
