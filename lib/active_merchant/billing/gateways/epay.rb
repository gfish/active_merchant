module ActiveMerchant #:nodoc:
 module Billing #:nodoc:
    class EpayGateway < Gateway
      API_HOST = 'yourpaymentsystem.net'
      SOAP_URL = 'https://' + API_HOST + '/remote/'

      self.default_currency = 'DKK'
      self.money_format = :cents
      self.supported_cardtypes = [:dankort, :forbrugsforeningen, :visa, :master,
                                  :american_express, :diners_club, :jcb, :maestro]
      self.supported_countries = ['DK', 'SE', 'NO']
      self.homepage_url = 'http://epay.dk/'
      self.display_name = 'ePay'

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

      # login: merchant number
      # password: referrer url (for authorize authentication)
      def initialize(options = {})
        requires!(options, :login)
        @options = options
        super
      end

      def authorize(money, credit_card_or_reference, options = {})
        post = {}

        add_amount(post, money, options)
        add_invoice(post, options)
        add_group(post, options)
        add_creditcard_or_reference(post, credit_card_or_reference)
        add_instant_capture(post, false)

        commit(:authorize, post)
      end

      def purchase(money, credit_card_or_reference, options = {})
        post = {}

        add_amount(post, money, options)
        add_creditcard_or_reference(post, credit_card_or_reference)
        add_invoice(post, options)
        add_instant_capture(post, true)

        commit(:authorize, post)
      end

      def capture(money, authorization, options = {})
        post = {}

        add_reference(post, authorization)
        add_amount_without_currency(post, money)

        commit(:capture, post)
      end

      def void(identification, options = {})
        post = {}

        add_reference(post, identification)

        commit(:void, post)
      end

      def refund(money, identification, options = {})
        post = {}

        add_amount_without_currency(post, money)
        add_reference(post, identification)

        commit(:credit, post)
      end

      def credit(money, identification, options = {})
        deprecated CREDIT_DEPRECATION_MESSAGE
        refund(money, identification, options)
      end

      def transaction_fee(money, credit_card_prefix, options = {})
        post = {}

        add_amount(post, money, options)
        add_credit_card_prefix(post, credit_card_prefix)

        commit(:get_card_info, post)
      end

      def get_transaction(identification)
        post = {}

        add_reference(post, identification)

        commit(:get_transaction, post)
      end

      def subscriber_authorize(money, subscriber, options = {})
        post = {}

        add_amount(post, money, options)
        add_subscriber(post, subscriber)
        add_invoice(post, options)
        add_group(post, options)
        add_instant_capture(post, options[:instant_capture])

        commit(:subscriber_authorize, post)
      end

      def unsubscribe(subscriber)
        post = {}

        add_subscriber(post, subscriber)

        commit(:delete_subscription, post)
      end

      def subscriptions(subscriber, options = {})
        post = {}

        add_subscriber(post, subscriber) if subscriber.present?

        commit(:get_subscriptions, post)
      end

      def epay_error(errorcode, options = {})
        post = {}

        add_epay_response_code(post, errorcode)
        add_language(post, options)

        commit(:get_epay_error, post)
      end

      private

      def add_amount(post, money, options)
        post[:amount]   = amount(money)
        post[:currency] = CURRENCY_CODES[(options[:currency] || currency(money)).to_sym]
      end

      def add_amount_without_currency(post, money)
        post[:amount] = amount(money)
      end

      def add_reference(post, identification)
        post[:transaction] = identification
      end

      def add_subscriber(post, subscriber)
        post[:subscription_id] = subscriber
      end

      def add_invoice(post, options)
        post[:orderid] = format_order_number(options[:order_id])
      end

      def add_group(post, options)
        post[:group] = options[:group] if options[:group].present?
      end

      def add_creditcard(post, credit_card)
        post[:cardno]   = credit_card.number
        post[:cvc]      = credit_card.verification_value
        post[:expmonth] = credit_card.month
        post[:expyear]  = credit_card.year
      end

      def add_creditcard_or_reference(post, credit_card_or_reference)
        if credit_card_or_reference.respond_to?(:number)
          add_creditcard(post, credit_card_or_reference)
        else
          add_reference(post, credit_card_or_reference.to_s)
        end
      end

      def add_credit_card_prefix(post, credit_card_prefix)
        post[:cardno_prefix] = credit_card_prefix
      end

      def add_instant_capture(post, option)
        post[:instantcapture] = option ? 1 : 0
      end

      def add_language(post, options)
        # 1 = Danish
        # 2 = English
        # 3 = Swedish
        post[:language] = options[:language] || 2
      end

      def add_epay_response_code(post, errorcode)
        post[:epayresponsecode] = errorcode
      end

      def commit(action, params)
        response = send("do_#{action}", params)

        if action == :authorize
          Response.new response['accept'].to_i == 1,
                       response['errortext'],
                       response,
                       :test => test?,
                       :authorization => response['tid']
        else
          Response.new response['result'] == 'true',
                       messages(response['epay'], response['pbs']),
                       response,
                       :test => test?,
                       :authorization => params[:transaction]
        end
      end

      def messages(epay, pbs = nil)
        response = "ePay: #{epay}"
        response << " PBS: #{pbs}" if pbs
        return response
      end

      def soap_post(service = "payment", method, params)
        data = xml_builder(params, service, method)
        headers = make_headers(data, service, method)
        REXML::Document.new(ssl_post('https://' + API_HOST + "/remote/#{service}.asmx", data, headers))
      end

      def do_authorize(params)
        headers = {}
        headers['Referer'] = options[:referrer] || 'activemerchant.org'

        response = raw_ssl_request(:post, 'https://' + API_HOST + '/auth/default.aspx', authorize_post_data(params), headers)

        # Authorize gives the response back by redirecting with the values in
        # the URL query
        if location = response['Location']
          query = CGI::parse(URI.parse(location.gsub(' ', '%20')).query)
        else
          return {
            'accept' => '0',
            'errortext' => 'No Location header returned.'
          }
        end

        result = {}
        query.each_pair do |k,v|
          result[k] = v.is_a?(Array) && v.size == 1 ? v[0] : v # make values like ['v'] into 'v'
        end
        result
      end

      def do_capture(params)
        response = soap_post('capture', params)
        {
          'result' => response.elements['//captureResponse/captureResult'].text,
          'pbs' => response.elements['//captureResponse/pbsResponse'].text,
          'epay' => response.elements['//captureResponse/epayresponse'].text
        }
      end

      def do_credit(params)
        response = soap_post('credit', params)
        {
          'result' => response.elements['//creditResponse/creditResult'].text,
          'pbs' => response.elements['//creditResponse/pbsresponse'].text,
          'epay' => response.elements['//creditResponse/epayresponse'].text
        }
      end

      def do_void(params)
        response = soap_post('delete', params)
        {
          'result' => response.elements['//deleteResponse/deleteResult'].text,
          'epay' => response.elements['//deleteResponse/epayresponse'].text
        }
      end

      def do_get_epay_error(params)
        response = soap_post('getEpayError', params)
        {
          'result' => response.elements['//getEpayErrorResponse/getEpayErrorResult'].text,
          'epayresponsestring' => response.elements['//getEpayErrorResponse/epayresponsestring'].text,
          'epay' => response.elements['//getEpayErrorResponse/epayresponse'].text
        }
      end

      def do_get_card_info(params)
        response = soap_post('getcardinfo', params)
        {
          'result' => response.elements['//getcardinfoResponse/getcardinfoResult'].text,
          'fee' => response.elements['//getcardinfoResponse/fee'].text,
          'cardtype' => response.elements['//getcardinfoResponse/cardtype'].text,
          'cardtypetext' => response.elements['//getcardinfoResponse/cardtypetext'].text,
          'epay' => response.elements['//getcardinfoResponse/epayresponse'].text
        }
      end

      def do_get_transaction(params)
        response = soap_post('gettransaction', params)
        {
          'result'         => response.elements['//gettransactionResponse/gettransactionResult'].text,
          'authamount'     => response.elements['//gettransactionResponse/transactionInformation/authamount'].text,
          'currency'       => response.elements['//gettransactionResponse/transactionInformation/currency'].text,
          'cardtypeid'     => response.elements['//gettransactionResponse/transactionInformation/cardtypeid'].text,
          'capturedamount' => response.elements['//gettransactionResponse/transactionInformation/capturedamount'].text,
          'creditedamount' => response.elements['//gettransactionResponse/transactionInformation/creditedamount'].text,
          'orderid'        => response.elements['//gettransactionResponse/transactionInformation/orderid'].text,
          'authdate'       => response.elements['//gettransactionResponse/transactionInformation/authdate'].text,
          'captureddate'   => response.elements['//gettransactionResponse/transactionInformation/captureddate'].text,
          'deleteddate'    => response.elements['//gettransactionResponse/transactionInformation/deleteddate'].text,
          'crediteddate'   => response.elements['//gettransactionResponse/transactionInformation/crediteddate'].text,
          'status'         => response.elements['//gettransactionResponse/transactionInformation/status'].text,
          'transactionid'  => response.elements['//gettransactionResponse/transactionInformation/transactionid'].text,
          'fee'            => response.elements['//gettransactionResponse/transactionInformation/fee'].text,
          'tcardno'        => response.elements['//gettransactionResponse/transactionInformation/tcardno'].text,
          'expmonth'       => response.elements['//gettransactionResponse/transactionInformation/expmonth'].text,
          'expyear'        => response.elements['//gettransactionResponse/transactionInformation/expyear'].text,
          'epay'           => response.elements['//gettransactionResponse/epayresponse'].text
        }
      end

      def do_subscriber_authorize(params)
        response = soap_post('subscription', 'authorize', params)
        {
          'result' => response.elements['//authorizeResponse/authorizeResult'].text,
          'tid' => response.elements['//authorizeResponse/transactionid'].text,
          'pbs' => response.elements['//authorizeResponse/pbsresponse'].text,
          'epay' => response.elements['//authorizeResponse/epayresponse'].text
        }
      end

      def do_delete_subscription(params)
        response = soap_post('subscription', 'deletesubscription', params)
        {
          'result' => response.elements['//deletesubscriptionResponse/deletesubscriptionResult'].text,
          'epay' => response.elements['//deletesubscriptionResponse/epayresponse'].text,
        }
      end

      # TODO: implement hash -> xml and xml -> hash
      def do_get_subscriptions(params)
        response = soap_post('subscription', 'getsubscriptions', params)

        if response.elements['//getsubscriptionsResponse/subscriptionAry'].size == 0
          {
            'result' => response.elements['//getsubscriptionsResponse/getsubscriptionsResult'].text,
            'epay' => response.elements['//getsubscriptionsResponse/epayresponse'].text
          }
        else
          {
            'result' => response.elements['//getsubscriptionsResponse/getsubscriptionsResult'].text,
            'subscriptionid' => response.elements['//getsubscriptionsResponse/subscriptionAry/SubscriptionInformationType/subscriptionid'].text,
            'cardtype' => response.elements['//getsubscriptionsResponse/subscriptionAry/SubscriptionInformationType/cardtypeid'].text,
            'expmonth' => response.elements['//getsubscriptionsResponse/subscriptionAry/SubscriptionInformationType/expmonth'].text,
            'expyear' => response.elements['//getsubscriptionsResponse/subscriptionAry/SubscriptionInformationType/expyear'].text,
            'epay' => response.elements['//getsubscriptionsResponse/epayresponse'].text
          }
        end
      end

      def make_headers(data, service, soap_call)
        {
          'Content-Type' => 'text/xml; charset=utf-8',
          'Host' => API_HOST,
          'Content-Length' => data.size.to_s,
          'SOAPAction' => SOAP_URL + service + '/' + soap_call
        }
      end

      def xml_builder(params, service, soap_call)
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
          xml.tag! 'soap:Envelope', { 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                                      'xmlns:xsd' => 'http://www.w3.org/2001/XMLSchema',
                                      'xmlns:soap' => 'http://schemas.xmlsoap.org/soap/envelope/' } do
            xml.tag! 'soap:Body' do
              xml.tag! soap_call, { 'xmlns' => SOAP_URL + service  } do
                xml.tag! 'merchantnumber', @options[:login]
                xml.tag! 'subscriptionid', params[:subscription_id] if params[:subscription_id]
                xml.tag! 'currency', params[:currency] if params[:currency]
                xml.tag! 'instantcapture', params[:instantcapture].to_s if params[:instantcapture]
                xml.tag! 'transactionid', params[:transaction] if params[:transaction]
                xml.tag! 'cardno_prefix', params[:cardno_prefix] if params[:cardno_prefix]
                xml.tag! 'epayresponsecode', params[:epayresponsecode] if params[:epayresponsecode]
                xml.tag! 'language', params[:language] if params[:language]
                xml.tag! 'amount', params[:amount].to_s if params[:amount]
                xml.tag! 'orderid', params[:orderid].to_s if params[:orderid]
                xml.tag! 'group', params[:group].to_s if params[:group]
                xml.tag! 'pwd', @options[:password] if @options[:password]
              end
            end
          end
        xml.target!
      end

      def authorize_post_data(params = {})
        params[:merchantnumber] = @options[:login]
        params[:language] = '2'
        params[:cms] = 'activemerchant'
        params[:accepturl] = 'https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx?accept=1'
        params[:declineurl] = 'https://ssl.ditonlinebetalingssystem.dk/auth/default.aspx?decline=1'
        params[:group] = params[:group].to_s if params[:group]
        params[:pwd] = @options[:password] if @options[:password]

        if @options[:md5]
          key_parts = [
            params[:currency],
            params[:amount],
            params[:orderid],
            @options[:md5]
          ]
          params[:md5key] = Digest::MD5.hexdigest(key_parts.join)
        end
        params.collect { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join("&")
      end

      # Limited to 20 digits max
      def format_order_number(number)
        number.to_s.gsub(/[^\w_]/, '').rjust(4, "0")[0...20]
      end
    end
  end
end
