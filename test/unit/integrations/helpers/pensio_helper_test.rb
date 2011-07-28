require 'test_helper'

class PensioHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = Pensio::Helper.new(
      1231,
      'Terminal Name', 
      :amount => 500, 
      :currency => 'SEK',
      :billing_address => {
        :city => 'My City',
        :region => 'Region2',
        :zip    => '2342',
        :country => 'Denmark'
      },
      :secret => 'secret'
    )
  end
 
  def test_basic_helper_fields
    assert_field 'terminal', 'Terminal Name'
    assert_field 'amount', '5.00'
    assert_field 'shop_orderid', '1231'
  end

  def test_basic_helper_fields
    assert_equal '752', @helper.form_fields['currency']
    assert_equal Digest::MD5.hexdigest("billing_city=My City,billing_country=Denmark,billing_postal=2342,billing_region=Region2,secret=secret"), @helper.form_fields['customer_info[checksum]']
  end
  
  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com'
    assert_field '', 'Cody'
    assert_field '', 'Fauser'
    assert_field '', 'cody@example.com'
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => '',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'
   
    assert_field '', '1 My Street'
    assert_field '', 'Leeds'
    assert_field '', 'Yorkshire'
    assert_field '', 'LS2 7EE'
  end
  
  def test_unknown_address_mapping
    @helper.billing_address :farm => 'CA'
    assert_equal 3, @helper.fields.size
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end
  
  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end
