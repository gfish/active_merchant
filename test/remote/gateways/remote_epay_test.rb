require 'test_helper'

class RemoteEpayTest < Test::Unit::TestCase
  def setup
    Base.gateway_mode = :test

    @gateway = EpayGateway.new(fixtures(:epay))

    @credit_card = credit_card('4444444444444000') # Dankort
    @credit_card_declined = credit_card('3333333333333102')
    @subscriber = "403060"

    @amount = 100
    @options = { :order_id => generate_unique_id }
  end

  def test_successful_authorization
    assert response = @gateway.authorize(@amount, @credit_card, @options)
    assert_equal "1", response.params['accept']
    assert_not_nil response.params['tid']
    assert_not_nil response.params['cur']
    assert_not_nil response.params['amount']
    assert_not_nil response.params['orderid']
    assert !response.authorization.blank?
    assert_success response
    assert response.test?
  end

  def test_failed_authorization
    assert response = @gateway.authorize(@amount, @credit_card_declined, @options)
    assert_equal '1', response.params['decline']
    assert_not_nil response.params['error']
    assert_not_nil response.params['errortext']
    assert_failure response
    assert response.test?
  end

  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_equal '1', response.params['accept']
    assert_not_nil response.params['tid']
    assert_not_nil response.params['cur']
    assert_not_nil response.params['amount']
    assert_not_nil response.params['orderid']
    assert !response.authorization.blank?
    assert_success response
    assert response.test?
  end

  def test_failed_purchase
    assert response = @gateway.purchase(@amount, @credit_card_declined, @options)
    assert_equal '1', response.params['decline']
    assert_not_nil response.params['error']
    assert_not_nil response.params['errortext']
    assert_failure response
    assert response.test?
  end

  def test_successful_capture
    authorize_response = @gateway.authorize(@amount, @credit_card, @options)

    assert response = @gateway.capture(@amount, authorize_response.authorization)
    assert_equal 'true', response.params['result']
    assert_success response
    assert response.test?
  end

  def test_failed_capture
    assert response = @gateway.capture(@amount, 0)
    assert_equal 'false', response.params['result']
    assert_failure response
    assert response.test?
  end

  def test_successful_refund
    authorize_response = @gateway.purchase(@amount, @credit_card, @options)

    assert response = @gateway.refund(@amount, authorize_response.authorization)
    assert_equal 'true', response.params['result']
    assert_success response
    assert response.test?
  end

  def test_failed_refund
    assert response_refund = @gateway.refund(@amount, 0)
    assert_equal 'false', response_refund.params['result']
    assert_failure response_refund
    assert response_refund.test?
  end

  def test_successful_void
    authorize_response = @gateway.authorize(@amount, @credit_card, @options)

    assert response = @gateway.void(authorize_response.authorization)
    assert_equal 'true', response.params['result']
    assert_success response
    assert response.test?
  end

  def test_failed_void
    assert response_void = @gateway.void(0)
    assert_equal 'false', response_void.params['result']
    assert_failure response_void
    assert response_void.test?
  end

  def test_transaction_fee
    assert response = @gateway.transaction_fee(@amount, 491761, :currency => :DKK)
    assert_equal 'true', response.params['result']
    assert_success response
    assert_equal 'VISA_ELECTRON_FOREIGN', response.params['cardtype']
    assert_equal '195', response.params['fee']
    assert_equal 'Visa/Electron (udenlandsk)', response.params['cardtypetext']
  end

  # this test is obviously completely dependent on a valid transaction
  def test_get_transaction
    assert response = @gateway.get_transaction(9376727)
    assert_equal 'true', response.params['result']
    assert_success response
    assert_equal '10100', response.params['authamount']
    assert_equal '208', response.params['currency']
    assert_equal '2', response.params['cardtypeid']
    assert_equal '0', response.params['capturedamount']
    assert_equal '0', response.params['creditedamount']
    assert_equal '2578', response.params['orderid']
    assert_equal '2012-03-21T13:58:00', response.params['authdate']
    assert_equal '0001-01-01T00:00:00', response.params['captureddate']
    assert_equal '0001-01-01T00:00:00', response.params['deleteddate']
    assert_equal '0001-01-01T00:00:00', response.params['crediteddate']
    assert_equal 'PAYMENT_NEW', response.params['status']
    assert_equal '444444XXXXXX4000', response.params['tcardno']
    assert_equal '1', response.params['expmonth']
    assert_equal '13', response.params['expyear']
  end

  def test_epay_error
    assert response = @gateway.epay_error(-1009)
    assert_equal 'true', response.params['result']
    assert_equal 'Subscription was not found.', response.params['epayresponsestring']
    assert_not_nil response.params['epay']
    assert_success response
    assert response.test?
  end

  # TODO: this test should first create a successfull subscription
  def test_successful_subscriber_authorization
    assert response = @gateway.subscriber_authorize(@amount, @subscriber, @options)
    assert_equal 'true', response.params['result']
    assert_not_nil response.params['tid']
    assert_not_nil response.params['pbs']
    assert_not_nil response.params['epay']
    assert_success response
    assert response.test?
  end

  # TODO: create a test with a failing amount
  def test_failed_subscriber_authorization
    assert response = @gateway.subscriber_authorize(@amount, 1234567, @options)
    assert_equal 'false', response.params['result']
    assert_not_nil response.params['tid']
    assert_not_nil response.params['pbs']
    assert_not_nil response.params['epay']
    assert_failure response
    assert response.test?
  end

  # TODO: this test should first create a successfull subscription
  def test_successful_subscriptions
    assert response = @gateway.subscriptions(@subscriber, @options)
    assert_equal 'true', response.params['result']
    assert_not_nil response.params['subscriptionid'] # TODO: implement xml -> hash to get all details
    assert_not_nil response.params['cardtype']
    assert_not_nil response.params['expmonth']
    assert_not_nil response.params['expyear']
    assert_not_nil response.params['epay']
    assert_success response
    assert response.test?
  end

  def test_failed_subscriptions
    assert response = @gateway.subscriptions(12345, @options)
    assert_equal 'true', response.params['result']
    assert_nil response.params['subscriptionid']
    assert_success response
    assert response.test?
  end

  # TODO: create a subscription before this test
  def test_successful_unsubscribe
    assert response = @gateway.unsubscribe(@subscriber)
    assert_equal 'true', response.params['result']
    assert_not_nil response.params['epay']
    assert_success response
    assert response.test?
  end

  def test_failed_unsubscribe
    assert response = @gateway.unsubscribe(12345)
    assert_equal 'false', response.params['result']
    assert_not_nil response.params['epay']
    assert_failure response
    assert response.test?
  end
end
