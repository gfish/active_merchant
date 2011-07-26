module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class PensioGateway < Gateway
      MERCHANT_TEST_URL = 'https://testgateway.pensio.com/merchant/'
      MERCHANT_LIVE_URL = 'https://gateway.pensio.com/merchant/'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.default_currency = 'DKK'
      self.supported_countries = ['DK','SE']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http:/www.pensio.com'
      
      # The name of the gateway
      self.display_name = 'Pensio'

      def self.currency_codes
        {
          :ADP => '020', :AED => '784', :AFA => '004', :ALL => '008', :AMD => '051',
          :ANG => '532', :AOA => '973', :ARS => '032', :AUD => '036', :AWG => '533',
          :AZM => '031', :BAM => '977', :BBD => '052', :BDT => '050', :BGL => '100',
          :BGN => '975', :BHD => '048', :BIF => '108', :BMD => '060', :BND => '096',
          :BOB => '068', :BOV => '984', :BRL => '986', :BSD => '044', :BTN => '064',
          :BWP => '072', :BYR => '974', :BZD => '084', :CAD => '124', :CDF => '976',
          :CHF => '756', :CLF => '990', :CLP => '152', :CNY => '156', :COP => '170',
          :CRC => '188', :CUP => '192', :CVE => '132', :CYP => '196', :CZK => '203',
          :DJF => '262', :DKK => '208', :DOP => '214', :DZD => '012', :ECS => '218',
          :ECV => '983', :EEK => '233', :EGP => '818', :ERN => '232', :ETB => '230',
          :EUR => '978', :FJD => '242', :FKP => '238', :GBP => '826', :GEL => '981',
          :GHC => '288', :GIP => '292', :GMD => '270', :GNF => '324', :GTQ => '320',
          :GWP => '624', :GYD => '328', :HKD => '344', :HNL => '340', :HRK => '191',
          :HTG => '332', :HUF => '348', :IDR => '360', :ILS => '376', :INR => '356',
          :IQD => '368', :IRR => '364', :ISK => '352', :JMD => '388', :JOD => '400',
          :JPY => '392', :KES => '404', :KGS => '417', :KHR => '116', :KMF => '174',
          :KPW => '408', :KRW => '410', :KWD => '414', :KYD => '136', :KZT => '398',
          :LAK => '418', :LBP => '422', :LKR => '144', :LRD => '430', :LSL => '426',
          :LTL => '440', :LVL => '428', :LYD => '434', :MAD => '504', :MDL => '498',
          :MGF => '450', :MKD => '807', :MMK => '104', :MNT => '496', :MOP => '446',
          :MRO => '478', :MTL => '470', :MUR => '480', :MVR => '462', :MWK => '454',
          :MXN => '484', :MXV => '979', :MYR => '458', :MZM => '508', :NAD => '516',
          :NGN => '566', :NIO => '558', :NOK => '578', :NPR => '524', :NZD => '554',
          :OMR => '512', :PAB => '590', :PEN => '604', :PGK => '598', :PHP => '608',
          :PKR => '586', :PLN => '985', :PYG => '600', :QAR => '634', :ROL => '642',
          :RUB => '643', :RUR => '810', :RWF => '646', :SAR => '682', :SBD => '090',
          :SCR => '690', :SDD => '736', :SEK => '752', :SGD => '702', :SHP => '654',
          :SIT => '705', :SKK => '703', :SLL => '694', :SOS => '706', :SRG => '740',
          :STD => '678', :SVC => '222', :SYP => '760', :SZL => '748', :THB => '764',
          :TJS => '972', :TMM => '795', :TND => '788', :TOP => '776', :TPE => '626',
          :TRL => '792', :TRY => '949', :TTD => '780', :TWD => '901', :TZS => '834',
          :UAH => '980', :UGX => '800', :USD => '840', :UYU => '858', :UZS => '860',
          :VEB => '862', :VND => '704', :VUV => '548', :XAF => '950', :XCD => '951',
          :XOF => '952', :XPF => '953', :YER => '886', :YUM => '891', :ZAR => '710',
          :ZMK => '894', :ZWD => '716'
        }
      end
      
      def initialize(options = {})
        #requires!(options, :login, :password)
        @options = options
        #ECOMMERCE_TEST_URL = 'http://testgateway.pensio.com/eCommerce/API/form/'
        #ECOMMERCE_LIVE_URL = "http://#{options[:subdomain]}.pensio.com/eCommerce/API/form/"
        super
      end  
      
      def authorize(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)        
        add_customer_data(post, options)
        
        commit('auth', money, post)
      end
      
      def purchase(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_address(post, creditcard, options)   
        add_customer_data(post, options)
             
        commit('sale', money, post)
      end                       
    
      def capture(money, authorization, options = {})
        commit('capture', money, post)
      end
    
      private                       
      
      def add_customer_data(post, options)
      end

      def add_address(post, creditcard, options)      
      end

      def add_invoice(post, options)
      end
      
      def add_creditcard(post, creditcard)      
      end
      
      def parse(body)
      end     

      def ecommerce_url
        if test?
          'http://testgateway.pensio.com/eCommerce/API/form/'
        else
          "http://#{@options[:subdomain]}.pensio.com/eCommerce/API/form/"
        end
      end
      
      def commit(action, money, parameters)
        url = if action == 'auth'
                ecommerce_url
              else
                test? ? MERCHANT_TEST_URL : MERCHANT_LIVE_URL
              end
        if action == 'auth'
          url
        else
          data = ssl_post(url, document.to_xml)
          parse(data)
        end
      end

      def message_from(response)
      end
      
      def post_data(action, parameters = {})
      end
    end
  end
end

