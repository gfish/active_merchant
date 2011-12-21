require 'test_helper'

class PensioHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = Pensio::Helper.new(
      1231,
      'Terminal Name', 
      :amount => 500, 
      :currency => 'SEK',
      :credential2 => 'secret',
      :credential3 => 'terminalname'
    )
    @helper.language = 'en'

  end
 
  def test_basic_helper_fields
    assert_field 'terminal', 'Terminal Name'
    assert_field 'amount', '5.00'
    assert_field 'shop_orderid', '1231'
  end

  def test_basic_helper_form_fields
    @helper.billing_address = {
      :city => 'My City',
      :region => 'Region2',
      :zip    => '2342',
      :country => 'Denmark',
      :first_name => 'John'
    }

    @helper.payment_type = 'payment'


    assert_equal '752', @helper.form_fields['currency']
    assert_equal "billing_city=My City,billing_country=Denmark,billing_firstname=John,billing_postal=2342,billing_region=Region2,secret=secret", @helper.generate_md5_string
    assert_equal Digest::MD5.hexdigest("billing_city=My City,billing_country=Denmark,billing_firstname=John,billing_postal=2342,billing_region=Region2,secret=secret"), @helper.form_fields['customer_info[checksum]']
    assert_equal 'en', @helper.form_fields['language']
    assert_equal '1231', @helper.form_fields['shop_orderid']
    assert_equal '5.00', @helper.form_fields['amount']
    assert_equal 'Terminal Name', @helper.form_fields['terminal']
    assert_equal 'payment', @helper.form_fields['type']
    assert_equal 'https://testgateway.pensio.com/eCommerce/API/form/', @helper.service_url
  end

  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com'
    assert_equal 'Cody', @helper.form_fields['customer_info[billing_firstname]']
    assert_equal 'Fauser', @helper.form_fields['customer_info[billing_lastname]']
    assert_equal 'cody@example.com', @helper.form_fields['customer_info[email]']
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => 'Stuff',
                            :city => 'Leeds',
                            :region => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'

    assert_equal '1 My Street', @helper.form_fields['customer_info[billing_address]']
    assert_equal 'Leeds', @helper.form_fields['customer_info[billing_city]']
    assert_equal 'Yorkshire', @helper.form_fields['customer_info[billing_region]']
    assert_equal 'LS2 7EE', @helper.form_fields['customer_info[billing_postal]']
    assert_equal 'CA', @helper.form_fields['customer_info[billing_country]']
  end

  def test_unknown_address_mapping
    @helper.billing_address :farm => 'CA'
    assert_equal 5, @helper.fields.size
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
