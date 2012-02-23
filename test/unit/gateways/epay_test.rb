require 'test_helper'

class EpayTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test

    @gateway = EpayGateway.new(
      :login    => '10100111001',
      :password => 'http://example.com'
    )

    @credit_card = credit_card
  end

  def test_successful_purchase
    @gateway.expects(:raw_ssl_request).returns(valid_authorize_response)

    assert response = @gateway.authorize(100, @credit_card)
    assert_success response
    assert_equal '123', response.authorization
  end

  def test_failed_purchase
    @gateway.expects(:raw_ssl_request).returns(invalid_authorize_response)

    assert response = @gateway.authorize(100, @credit_card)
    assert_failure response
    assert_equal 'The payment was declined. Try again in a moment or try with another credit card.',
                 response.message
  end

  def test_successful_capture
    @gateway.expects(:soap_post).returns(REXML::Document.new(valid_capture_response))

    assert response = @gateway.capture(100, '123')
    assert_success response
    assert_equal 'ePay: -1 PBS: 0', response.message
  end

  def test_failed_capture
    @gateway.expects(:soap_post).returns(REXML::Document.new(invalid_capture_response))

    assert response = @gateway.capture(100, '123')
    assert_failure response
    assert_equal 'ePay: -1008 PBS: -1', response.message
  end

  def test_successful_void
    @gateway.expects(:soap_post).returns(REXML::Document.new(valid_void_response))

    assert response = @gateway.void('123')
    assert_success response
    assert_equal 'ePay: -1', response.message
  end

  def test_failed_void
    @gateway.expects(:soap_post).returns(REXML::Document.new(invalid_void_response))

    assert response = @gateway.void('123')
    assert_failure response
    assert_equal 'ePay: -1008', response.message
  end

  def test_successful_refund
    @gateway.expects(:soap_post).returns(REXML::Document.new(valid_refund_response))

    assert response = @gateway.refund(100, '123')
    assert_success response
    assert_equal 'ePay: -1 PBS: 0', response.message
  end

  def test_failed_refund
    @gateway.expects(:soap_post).returns(REXML::Document.new(invalid_refund_response))

    assert response = @gateway.refund(100, '123')
    assert_failure response
    assert_equal 'ePay: -1008 PBS: -1', response.message
  end

  def test_deprecated_credit
    @gateway.expects(:soap_post).returns(REXML::Document.new(valid_refund_response))
    assert_deprecation_warning(Gateway::CREDIT_DEPRECATION_MESSAGE, @gateway) do
      assert_success @gateway.credit(100, '123')
    end
  end

  def test_authorize_sends_order_number
    @gateway.expects(:raw_ssl_request).with(anything, anything, regexp_matches(/orderid=1234/), anything).returns(valid_authorize_response)

    assert response = @gateway.authorize(100, '123', :order_id => '#1234')
  end
  
  def test_purchase_sends_order_number
    @gateway.expects(:raw_ssl_request).with(anything, anything, regexp_matches(/orderid=1234/), anything).returns(valid_authorize_response)

    assert response = @gateway.purchase(100, '123', :order_id => '#1234')
  end

  def test_subscriber_authorization
    @gateway.expects(:soap_post).returns(REXML::Document.new(valid_subscriber_authorization_response))

    assert response = @gateway.subscriber_authorize(100, '123456', :order_id => '#1234')
    assert_success response
  end

  def test_failed_subscriber_authorization
    @gateway.expects(:soap_post).returns(REXML::Document.new(invalid_subscriber_authorization_response))

    assert response = @gateway.subscriber_authorize(100, '123456', :order_id => '#1234')
    assert_failure response
    assert_equal 'ePay: -1009 PBS: -1', response.message
  end

  def test_failed_unsubscribe
    @gateway.expects(:soap_post).returns(REXML::Document.new(valid_unsubscribe_response))

    assert response = @gateway.unsubscribe(123456)
    assert_success response
    assert_equal 'ePay: -1009', response.message
  end

  def test_failed_unsubscribe
    @gateway.expects(:soap_post).returns(REXML::Document.new(invalid_unsubscribe_response))

    assert response = @gateway.unsubscribe(123456)
    assert_failure response
    assert_equal 'ePay: -1009', response.message
  end

  def test_epay_error
    @gateway.expects(:soap_post).returns(REXML::Document.new(valid_epay_error_response))

    assert response = @gateway.epay_error(-1009)
    assert_success response
    assert_equal 'Subscription was not found.', response.params['epayresponsestring']
  end
  
  private

  def valid_authorize_response
    { 'Location' => 'https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx?accept=1&tid=123&&amount=100&cur=208&date=20101117&time=2357&cardnopostfix=3000&fraud=1&cardid=18&transfee=0' }
  end

  def invalid_authorize_response
    { 'Location' => 'https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx?decline=1&error=102&errortext=The payment was declined. Try again in a moment or try with another credit card.' }
  end

  def valid_capture_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><captureResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/payment"><captureResult>true</captureResult><pbsResponse>0</pbsResponse><epayresponse>-1</epayresponse></captureResponse></soap:Body></soap:Envelope>'
  end

  def invalid_capture_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><captureResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/payment"><captureResult>false</captureResult><pbsResponse>-1</pbsResponse><epayresponse>-1008</epayresponse></captureResponse></soap:Body></soap:Envelope>'
  end

  def valid_void_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><deleteResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/payment"><deleteResult>true</deleteResult><epayresponse>-1</epayresponse></deleteResponse></soap:Body></soap:Envelope>'
  end

  def invalid_void_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><deleteResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/payment"><deleteResult>false</deleteResult><epayresponse>-1008</epayresponse></deleteResponse></soap:Body></soap:Envelope>'
  end

  def valid_refund_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><creditResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/payment"><creditResult>true</creditResult><pbsresponse>0</pbsresponse><epayresponse>-1</epayresponse></creditResponse></soap:Body></soap:Envelope>'
  end

  def valid_subscriber_authorization_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><authorizeResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/subscription"><authorizeResult>true</authorizeResult><fraud>0</fraud><transactionid>8955361</transactionid><pbsresponse>0</pbsresponse><epayresponse>-1</epayresponse></authorizeResponse></soap:Body></soap:Envelope>'
  end

  def invalid_subscriber_authorization_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><authorizeResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/subscription"><authorizeResult>false</authorizeResult><fraud>0</fraud><transactionid>0</transactionid><pbsresponse>-1</pbsresponse><epayresponse>-1009</epayresponse></authorizeResponse></soap:Body></soap:Envelope>'
  end

  def invalid_refund_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><creditResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/payment"><creditResult>false</creditResult><pbsresponse>-1</pbsresponse><epayresponse>-1008</epayresponse></creditResponse></soap:Body></soap:Envelope>'
  end

  def valid_epay_error_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><getEpayErrorResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/payment"><getEpayErrorResult>true</getEpayErrorResult><epayresponsestring>Subscription was not found.</epayresponsestring><epayresponse>-1</epayresponse></getEpayErrorResponse></soap:Body></soap:Envelope>'
  end

  def valid_unsubscribe_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><deletesubscriptionResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/subscription"><deletesubscriptionResult>true</deletesubscriptionResult><epayresponse>-1</epayresponse></deletesubscriptionResponse></soap:Body></soap:Envelope>'
  end

  def invalid_unsubscribe_response
    '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><deletesubscriptionResponse xmlns="https://ssl.ditonlinebetalingssystem.dk/remote/subscription"><deletesubscriptionResult>false</deletesubscriptionResult><epayresponse>-1009</epayresponse></deletesubscriptionResponse></soap:Body></soap:Envelope>'
  end
end
