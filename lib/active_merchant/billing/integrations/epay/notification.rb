require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Epay
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          self.production_ips = [ '87.54.46.121', '87.54.46.122' ]

          MD5_FIELDS = [
            :amount, :orderid, :tid
          ]

          def complete?
            status == 'OK'
          end 

          def item_id
				    params['orderid']
          end

          def transaction_id
				    params['tid']
          end

          # When was this payment received by the client. 
          def received_at
            params['date'] + params['time']
          end

          def payer_email
            params['']
          end

          def receiver_email
            params['']
          end 

          def security_key
            params['']
          end

          def transfer_fee
            params['transfee']
          end

          def currency
            if params['cur']
              ActiveMerchant::Billing::EpayGateway::CURRENCY_CODES.invert[params['cur'].to_s].to_s
            else
              ActiveMerchant::Billing::EpayGateway.default_currency
            end
          end

          def gross
            params['amount'].to_f if params['amount']
          end

          #
          # Was this a test transaction?
          def test?
            params['test'] == 'test'
          end

          def error_text
            CGI.unescape(params['errortext'])
          end

          def error?
            status == 'ERROR'
          end

          def status
            if params['error']
              'ERROR'
            elsif valid_checksum?
              'OK'
            else
              'FAILED'
            end
          end

          def valid_checksum?
            @options[:md5] and params['eKey'] and params['eKey'] == generate_md5_key
          end

          def generate_md5_key
            Digest::MD5.hexdigest(MD5_FIELDS.map {|key| params[key.to_s]} * "" + @options[:md5])
          end

          def acknowledge
            valid_checksum?
          end
 private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end
        end
      end
    end
  end
end
