require 'test_helper'

class PensioTest < Test::Unit::TestCase
  def setup
    @gateway = PensioGateway.new({
                 :terminal => 'Terminal Name',
                 :subdomain => "thesubdomain"
    })

    @credit_card = nil
    @amount = 100
    
    @options = { 
      :shop_orderid => '1',
      :currency => 'DKK'
    }
  end

  def test_redirect_url
    assert_equal "https://testgateway.pensio.com/eCommerce/API/form/?shop_orderid=1&terminal=Terminal+Name&currency=208&amount=1.00", @gateway.redirect_url(@amount, @options)
  end
  
  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_instance_of 
    assert_success response
    
    # Replace with authorization number from the successful response
    assert_equal '', response.authorization
    assert response.test?
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_post).returns(failed_purchase_response)
    
    assert response = @gateway.purchase(@amount, @credit_card, @options)
    assert_failure response
    assert response.test?
  end

  private
  
  # Place raw successful response from gateway here
  def successful_purchase_response
  end
  
  # Place raw failed response from gateway here
  def failed_purcahse_response
  end
end
