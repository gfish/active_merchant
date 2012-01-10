require 'test_helper'

class EpayNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @epay = Epay::Notification.new(http_raw_data, :md5 => '5f14e8785eb78a0')
  end

  def test_accessors
    assert_equal "8010276", @epay.transaction_id
    assert_equal "263", @epay.item_id
    assert_equal 14925.0, @epay.gross
    assert_equal "DKK", @epay.currency
    assert_equal "201112141300", @epay.received_at
    assert_equal "0", @epay.transfer_fee
    assert_equal "4000", @epay.card_number_postfix
    assert_equal "444444XXXXXX4000", @epay.card_number
    assert_equal "2", @epay.card_type
  end

  def test_compositions
    assert_equal Money.new(1492500, 'DKK'), @epay.amount
  end

  def test_respond_to_acknowledge
    assert @epay.respond_to?(:acknowledge)
  end

  def test_payment_accepted
    assert_equal "OK", @epay.status
    assert_equal true, @epay.complete?
  end

  def test_payment_failed
    epay_failed = Epay::Notification.new(http_raw_fail_data, :md5 => '5f14e8785eb78a0')
    assert_equal "ERROR", epay_failed.status
    assert_equal "310", epay_failed.item_id
    assert_equal "Afvist - Ring til kort udstederen", epay_failed.error_text
  end
  
  private

  def http_raw_data
    "tid=8010276&orderid=263&amount=14925&cur=208&date=20111214&time=1300&&eKey=04e10ed26ded935596e18da80971a817&transfee=0&cardnopostfix=4000&tcardno=444444XXXXXX4000&cardid=2"
  end  
  
  def http_raw_fail_data
    "error=1&orderid=310&errortext=Afvist%20-%20Ring%20til%20kort%20udstederen"
  end
end
