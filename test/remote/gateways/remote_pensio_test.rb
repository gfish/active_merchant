require 'test_helper'

class RemotePensioTest < Test::Unit::TestCase
  

  def setup
    @gateway = PensioGateway.new(fixtures(:pensio))
    
    @credit_card = {:cardnum => '4000000000000000',
                    :emonth => '04',
                    :eyear  => '2012',
                    :cvc    => '234'}
    @declined_card = credit_card('4000300011112220')
    @money = Money.new(100,'SEK')
    @amount = 100
    @options = {:order_id => 1}
  end
  
  def test_successful_authorize
    assert response = @gateway.authorize(@money, @credit_card, @options)
    assert_success response
    assert_equal 'Success', response.message
  end

  def test_authorize_and_capture
    amount = @amount
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert_equal 'Success', auth.message
    assert auth.authorization
    assert capture = @gateway.capture(amount, auth.authorization)
    assert_success capture
    assert_equal 'Success', capture.message
  end

  def test_failed_capture
    assert response = @gateway.capture(@amount, '')
    assert_failure response
    assert_equal "Transaction ID '' does not exist.", response.message
  end

  def test_authorize_and_void
    amount = @amount
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert_equal 'Success', auth.message
    assert auth.authorization
    assert capture = @gateway.void(amount, auth.authorization)
    assert_success capture
    assert_equal 'Success', capture.message
  end

  def test_authorize_and_void_and_capture_failure
    amount = @amount
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert_equal 'Success', auth.message
    assert auth.authorization
    assert void = @gateway.void(amount, auth.authorization)
    assert_success void
    assert_equal 'Success', void.message
    assert capture = @gateway.capture(amount, auth.authorization)
    assert_failure capture
    assert_equal 'Error', capture.message
  end

  def test_capture_and_refund
    amount = @amount
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert_equal 'Success', auth.message
    assert auth.authorization
    assert capture = @gateway.capture(amount, auth.authorization)
    assert_success capture
    assert refund = @gateway.refund(amount, auth.authorization)
    assert_success refund
    assert_equal 'Success', refund.message
  end

  def test_capture_failed
    #special amounts and cardpostfixes to generate errors
    @credit_card = {:cardnum => '4000000000000766',
                    :emonth => '04',
                    :eyear  => '2012',
                    :cvc    => '234'}
    amount = 766
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert capture = @gateway.capture(amount, auth.authorization, @options)
    assert_failure capture
    assert_equal 'Failed', capture.message
  end

  def test_capture_error
    #special amounts and cardpostfixes to generate errors
    @credit_card = {:cardnum => '4000000000000767',
                    :emonth => '04',
                    :eyear  => '2012',
                    :cvc    => '234'}
    amount = 767
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert capture = @gateway.capture(amount, auth.authorization, @options)
    assert_failure capture
    assert_equal 'Error', capture.message
  end

  def test_void_failure
    #special amounts and cardpostfixes to generate errors
    @credit_card = {:cardnum => '4000000000000866',
                    :emonth => '04',
                    :eyear  => '2012',
                    :cvc    => '234'}
    amount = 866
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert void = @gateway.void(amount, auth.authorization)
    assert_failure void
    assert_equal 'Failed', void.message
  end

  def test_void_error
    #special amounts and cardpostfixes to generate errors
    @credit_card = {:cardnum => '4000000000000867',
                    :emonth => '04',
                    :eyear  => '2012',
                    :cvc    => '234'}
    amount = 867
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert void = @gateway.void(amount, auth.authorization)
    assert_failure void
    assert_equal 'Error', void.message
  end

  def test_authorize_capture_and_refund_failure
    #special amounts and cardpostfixes to generate errors
    @credit_card = {:cardnum => '4000000000000966',
                    :emonth => '04',
                    :eyear  => '2012',
                    :cvc    => '234'}
    amount = 966
    amount = @amount
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert_equal 'Success', auth.message
    assert auth.authorization
    assert capture = @gateway.capture(amount, auth.authorization)
    assert_success capture
    assert refund = @gateway.refund(amount, auth.authorization)
    assert_failure refund
    assert_equal 'Failed', refund.message
  end

  def test_authorize_capture_and_refund_error
    #special amounts and cardpostfixes to generate errors
    @credit_card = {:cardnum => '4000000000000967',
                    :emonth => '04',
                    :eyear  => '2012',
                    :cvc    => '234'}
    amount = 967
    amount = @amount
    assert auth = @gateway.authorize(amount, @credit_card, @options)
    assert_success auth
    assert_equal 'Success', auth.message
    assert auth.authorization
    assert capture = @gateway.capture(amount, auth.authorization)
    assert_success capture
    assert refund = @gateway.refund(amount, auth.authorization)
    assert_failure refund
    assert_equal 'Error', refund.message
  end
end
