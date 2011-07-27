require 'digest/md5'

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
        CURRENCY_CODES
      end

      CURRENCY_CODES = {
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
      
      #API User username and password
      def initialize(options = {})
        requires!(options, :login, :password)
        @options = options
        @options[:http_basic_auth] = @options.delete[:login]
        @options[:http_basic_auth_password] = @options.delete[:login]
        super
      end  
      

      def self.redirect_url(money, options = {})
        build_redirect_url(money, options)
      end

      #This is the MO/TO transaction
      #def authorize(money, creditcard, options = {})
      #  post = {}
      #  add_amount(post, money, options)
      #  add_invoice(post, options)
      #  add_creditcard(post, creditcard)        
      #  add_address(post, creditcard, options)        
      #  add_customer_data(post, options)
      #  
      #  commit('reservationOfFixedAmountMTOT', money, post)
      #end
      
      #def purchase(money, creditcard, options = {})
      #  post = {}
      #  add_invoice(post, options)
      #  add_creditcard(post, creditcard)        
      #  add_address(post, creditcard, options)   
      #  add_customer_data(post, options)
      #       
      #  commit('sale', money, post)
      #end                       
    
      #orderlines takes an array of hashes
      def capture(authorization, money = nil, order_lines = [])
        post = {}
        add_transaction_id(transaction_id)
        add_amount_without_currency(money)
        add_order_lines(order_lines)
        commit('captureReservation', post)
      end

      #transaction_id required
      #amount optional
      def refund(transaction_id, money = nil)
        post = {}
        add_transaction(post,transaction_id)
        add_amount_without_currency(post,money)
        commit('refundCapturedReservation', post)
      end

      def release_reservation(transaction_id)
        post = {}
        add_transaction(post,transaction_id)
        commit('releaseReservation', post)
      end

      def all_payments(options = {})
        commit('payments', options)
      end

      #transaction_id required
      #amount optional
      def capture_recurring(transaction_id, money = nil)
        post = {}
        add_transaction(post, transaction_id)
        add_amount_without_currency(post, money)
        commit('captureRecurring', post)
      end

      #transaction_id required
      #amount optional
      def preauth_recurring(transaction_id, money = nil)
        post = {}
        add_transaction(post, transaction_id)
        add_amount_without_currency(post, money)
        commit('preauthRecurring', post)
      end

      def funding_list(page = nil)
        post = {}
        post[:page] = page if page

        commit('fundingList', post)
      end
      
      def funding_download(funding_id)
        post = {}
        post[:id] = funding_id

        commit('fundingDownload', post)
      end
    
      private                       

      def add_amount(post, money, options = {})
        post[:amount]   = amount(money)
        post[:currency] = CURRENCY_CODES[(options[:currency] || currency(money)).to_sym]
      end

      def add_amount_without_currency(post, money, options = {})
        post[:amount]   = amount(money) if money
      end

      def add_transaction_id(post,transaction_id)
        post[:transaction_id] = transaction_id
      end

      def add_order_lines(order_lines)
        unless order_lines.empty?
          i = 0
          order_lines.inject({}) do |result,line|
            line.each do |key,value|
              result["orderLines[#{i.to_s}][#{key.to_s}]"] = value.to_s
            end

            i += 1
            result
          end
        end
      end
      
      def add_invoice(post, options)
        post[:shop_orderid] ||= options[:order_id]
      end
      
      def commit(action, params)
        response = parse(ssl_post(post_data(action,params)))
      end

      def parse(data)
        response = {}

        doc = REXML::Document.new(data)

        doc.root.elements.each do |element|
          response[element.name.to_sym] = element.text
        end

        response
      end

      def url(action)
        str = ""
        str << test? ? TEST_URL : LIVE_URL
        str << action + "/"
        str
      end

      def post_data(action, params = {})
        str = ""
        str << url(action)
        str << "?"
        str << params.collect{|k,v| "#{k.to_s}=#{CGI.escape(v.to_s)}"}.join("&")
        str
      end

      def build_redirect_url(money, options)
        secret  = options.delete(:secret)
        if subdomain
          subdomain = options.delete(:subdomain)
        elsif !test?
          raise "No subdomain is set for Pensio"
        end

        unless options[:terminal]
          raise "No Terminal is set for Pensio redirect URL"
        end

        if generate_md5_string
          options["customer_info[checksum]"] = generate_md5_string
        end

        options[:amount] = amount(money)
        options[:currency] = CURRENCY_CODES[(options[:currency] || currency(money)).to_sym]
        options[:shop_orderid] ||= options.delete[:order_id]
        params_str = options.collect do |key,value|
          "#{key}=#{CGI.escape(value.to_s)}"
        end.join("&")

        self.ecommerce_url(subdomain) + "?" + params_str
      end

      def self.fraud_detection_fields
        %w(email username customer_phone bank_name bank_phone billing_firstname billing_lastname billing_address shipping_firstname shipping_lastname shipping_address shipping_city shipping_region shipping_postal shipping_country).inject({}) do |result, str|
          result["customer_info[#{str}]"] = str
          result
        end
      end

      def generate_md5_string
        if @secret.present? && self.fraud_detection_fields.any?{|ci_field,field| ci_field == options.keys.maps{|k| k.to_s}}
          hash = self.fraud_detection_fields.inject({}) do |result, (ci_field,field)|
            result[field] = options[ci_field.to_sym] if options[ci_field.to_sym]
            result
          end.merge("secret" => @secret)

          hash.sort{|a,b| a[0] <=> b[0]}.map{|fv| "#{fv[0]}=#{fv[1]}"}.join(",")
        end
      end

      def generate_md5_key
        if generate_md5_string
          Digest::MD5.hexdigest(generate_md5_string)
        else
          nil
        end
      end

      def self.ecommerce_url(subdomain)
        if test?
          'https://testgateway.pensio.com/eCommerce/API/form/'
        else
          "https://#{subdomain}.pensio.com/eCommerce/API/form/"
        end
      end
      
    end
  end
end

