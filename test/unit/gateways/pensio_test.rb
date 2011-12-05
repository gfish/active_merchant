require 'test_helper'

class PensioTest < Test::Unit::TestCase
  def setup
    @gateway = PensioGateway.new(
      :login =>    'login',
      :password => 'password',
      :terminal => 'Pensio Test Terminal'
    )

    @credit_card = nil
    @amount = 1000
    @money = Money.new(1000, "SEK")
    
    @options = { 
      :order_id => '1',
    }
  end

  def test_successful_capture
    @gateway.expects(:ssl_get).returns(successful_capture_response)
    
    assert response = @gateway.authorize(@money, @credit_card, @options)
    assert_success response
    assert_instance_of Response, response
    # Replace with authorization number from the successful response
    #assert_equal '', response.authorization
    #assert response.test?

    assert_equal 'Success', response.params["body"]['result']
    assert_equal 'Pensio Test Terminal', response.params["body"]["transactions"]["transaction"]['terminal']
    assert_equal successful_capture_response, response.params['dump']
  end

  def test_successful_capture_with_currency
    @gateway.expects(:ssl_get).returns(successful_capture_response)
    
    @options = {
      :order_id => '1',
      :currency => 'SEK',
    }

    assert response = @gateway.authorize(@amount, @credit_card, @options)
    assert_success response
    assert_instance_of Response, response
    # Replace with authorization number from the successful response
    #assert_equal '', response.authorization
    #assert response.test?

    assert_equal 'Success', response.params["body"]['result']
  end

  def test_unsuccessful_request
    @gateway.expects(:ssl_get).returns(failed_authorize_response)
    
    assert response = @gateway.authorize(@amount, @credit_card, @options)
    assert_failure response
    #assert response.test?
  end

  private
  
  def successful_capture_response
    str = <<XML
<?xml version="1.0" encoding="utf-8" ?> <APIResponse version="20100929">
<Header> <Date>2010-09-29T12:34:56+02:00</Date> <Path>API/captureReservation</Path> <ErrorCode>0</ErrorCode> <ErrorMessage></ErrorMessage>
</Header> <Body>
<CaptureAmount>0.20</CaptureAmount> <CaptureCurrency>978</CaptureCurrency> <Result>Success</Result> <CaptureResult>Success</CaptureResult> <!-- deprecated --> <Transactions>
<Transaction> <TransactionId>1</TransactionId> <CardStatus>Valid</CardStatus> <CreditCardToken>93f534a2f5d66d6ab3f16c8a7bb7e852656d4bb2</CreditCardToken>
<CreditCardMaskedPan>411111******1111</CreditCardMaskedPan> <ShopOrderId>myorderid</ShopOrderId> <Shop>Pensio Shop</Shop> <Terminal>Pensio Test Terminal</Terminal> <TransactionStatus>captured</TransactionStatus> <MerchantCurrency>978</MerchantCurrency> <CardHolderCurrency>978</CardHolderCurrency> <ReservedAmount>1.00</ReservedAmount> <CapturedAmount>1.00</CapturedAmount> <RefundedAmount>0</RefundedAmount> <RecurringMaxAmount>0</RecurringMaxAmount> <CreatedDate>2010-09-28 12:34:56</CreatedDate> <UpdatedDate>2010-09-28 12:34:56</UpdatedDate> <FraudRiskScore>13.37</FraudRiskScore> <FraudExplanation>Fraud detection explanation</FraudExplanation> <TransactionInfo>
<Form_Created_At>2010-09-28 12:34:56</Form_Created_At> <Form_Provider>Pensio Test Form</Form_Provider> <Merchant_Provided_Info>Some info by merchant</Merchant_Provided_Info>
</TransactionInfo> <ReconciliationIdentifiers>
<ReconciliationIdentifier> <Id>f4e2533e-c578-4383-b075-bc8a6866784a</Id> <Amount currency="978">1.00</Amount> <Type>captured</Type> <Date>2010-09-28T12:00:00+02:00</Date>
</ReconciliationIdentifier> </ReconciliationIdentifiers>
</Transaction> </Transactions>
</Body> </APIResponse>
XML
    str
  end

  def successful_void_response
    <<XML
<?xml version="1.0" encoding="utf-8" ?> <APIResponse version="20100929">
<Header> <Date>2010-09-29T12:34:56+02:00</Date> <Path>API/releaseReservation</Path> <ErrorCode>0</ErrorCode> <ErrorMessage></ErrorMessage>
</Header> <Body>
<Result>Success</Result> <CancelResult>Success</CancelResult> <!-- deprecated --> <Transactions>
<Transaction> <TransactionId>1</TransactionId> <CardStatus>Valid</CardStatus> <CreditCardToken>93f534a2f5d66d6ab3f16c8a7bb7e852656d4bb2</CreditCardToken> <CreditCardMaskedPan>411111******1111</CreditCardMaskedPan> <ShopOrderId>myorderid</ShopOrderId> <Shop>Pensio Shop</Shop> <Terminal>Pensio Test Terminal</Terminal> <TransactionStatus>cancelled</TransactionStatus> <MerchantCurrency>978</MerchantCurrency> <CardHolderCurrency>978</CardHolderCurrency> <ReservedAmount>1.00</ReservedAmount> <CapturedAmount>0</CapturedAmount> <RefundedAmount>0</RefundedAmount> <RecurringMaxAmount>0</RecurringMaxAmount> <CreatedDate>2010-09-28 12:34:56</CreatedDate> <UpdatedDate>2010-09-28 12:34:56</UpdatedDate> <FraudRiskScore>13.37</FraudRiskScore> <FraudExplanation>Fraud detection explanation</FraudExplanation> <TransactionInfo>
<Form_Created_At>2010-09-28 12:34:56</Form_Created_At> <Form_Provider>Pensio Test Form</Form_Provider> <Merchant_Provided_Info>Some info by merchant</Merchant_Provided_Info>
</TransactionInfo>
<ReconciliationIdentifiers/> </Transaction>
</Transactions> </Body>
</APIResponse>
XML
  end

  def successful_refund_response
    <<XML
<?xml version="1.0" encoding="utf-8" ?> <APIResponse version="20100929">
<Header> <Date>2010-09-29T12:34:56+02:00</Date> <Path>API/refundCapturedReservation</Path> <ErrorCode>0</ErrorCode> <ErrorMessage></ErrorMessage>
</Header> <Body>
<RefundAmount>0.12</RefundAmount> <RefundCurrency>978</RefundCurrency> <Result>Success</Result> <RefundResult>Success</RefundResult> <!-- deprecated --> <Transactions>
<Transaction> <TransactionId>1</TransactionId> <CardStatus>Valid</CardStatus> <CreditCardToken>93f534a2f5d66d6ab3f16c8a7bb7e852656d4bb2</CreditCardToken> <CreditCardMaskedPan>411111******1111</CreditCardMaskedPan> <ShopOrderId>myorderid</ShopOrderId> <Shop>Pensio Shop</Shop> <Terminal>Pensio Test Terminal</Terminal> <TransactionStatus>refunded</TransactionStatus> <MerchantCurrency>978</MerchantCurrency> <CardHolderCurrency>978</CardHolderCurrency> <ReservedAmount>1.00</ReservedAmount> <CapturedAmount>1.00</CapturedAmount> <RefundedAmount>0.12</RefundedAmount> <RecurringMaxAmount>0</RecurringMaxAmount> <CreatedDate>2010-09-28 11:34:56</CreatedDate> <UpdatedDate>2010-09-28 13:00:00</UpdatedDate> <FraudRiskScore>13.37</FraudRiskScore> <FraudExplanation>Fraud detection explanation</FraudExplanation> <TransactionInfo>
<Form_Created_At>2010-09-28 12:34:56</Form_Created_At>
<Form_Provider>Pensio Test Form</Form_Provider>
<Merchant_Provided_Info>Some info by merchant</Merchant_Provided_Info> </TransactionInfo> <ReconciliationIdentifiers>
<ReconciliationIdentifier> <Id>f4e2533e-c578-4383-b075-bc8a6866784a</Id> <Amount currency="978">1.00</Amount> <Type>captured</Type> <Date>2010-09-28T12:00:00+02:00</Date>
</ReconciliationIdentifier> <ReconciliationIdentifier>
<Id>8774bcef-7549-4497-948e-82280ca69f80</Id> <Amount currency="978">0.12</Amount> <Type>refunded</Type> <Date>2010-09-28T13:00:00+02:00</Date>
</ReconciliationIdentifier> </ReconciliationIdentifiers>
</Transaction> </Transactions>
</Body> </APIResponse>

XML
  end

  def successful_authorize_response
    <<XML
<?xml version="1.0"?> <APIResponse version="20100929">
<Header> <Date>2010-09-29T12:34:56+02:00</Date> <Path>API/reservationOfFixedAmountMOTO</Path> <ErrorCode>0</ErrorCode>
<ErrorMessage></ErrorMessage> </Header> <Body>
<Result>Success</Result> <Transactions>
<Transaction> <TransactionId>3</TransactionId> <CardStatus>Valid</CardStatus> <CreditCardToken>85c1d13de7b5dceb6b739829cc27e089631b0fda</CreditCardToken> <CreditCardMaskedPan>411111******1111</CreditCardMaskedPan> <ShopOrderId>myorder123</ShopOrderId> <Shop>Pensio Functional Test Shop</Shop> <Terminal>Pensio Test Terminal</Terminal> <TransactionStatus>preauth</TransactionStatus> <MerchantCurrency>978</MerchantCurrency> <CardHolderCurrency>978</CardHolderCurrency> <ReservedAmount>2499.95</ReservedAmount> <CapturedAmount>0</CapturedAmount> <RefundedAmount>0</RefundedAmount> <RecurringMaxAmount>0</RecurringMaxAmount> <CreatedDate>2010-09-28 12:34:56</CreatedDate> <UpdatedDate>2010-09-28 12:34:56</UpdatedDate> <TransactionInfo>
<Payment_Type>payment</Payment_Type> </TransactionInfo> <ReconciliationIdentifiers/>
</Transaction> </Transactions>
</Body> </APIResponse>
XML
  end

  def failed_authorize_response
    <<XML
<?xml version="1.0"?> <APIResponse version="20100929">
<Header> <Date>2010-02-12T21:45:52+01:00</Date> <Path>API/reservationOfFixedAmountMOTO</Path> <ErrorCode>762813994</ErrorCode> <ErrorMessage>No credit card with selected token exists:
0a4d55a8d778e5022fab701977c5d840bbc486d0</ErrorMessage> </Header> <Body/>
</APIResponse>
XML
  end
end
