# frozen_string_literal: true

require 'dry/transaction'
require 'uri'
require 'net/http'
require 'jwt'

module NoFB
  module Service
    # Service object interacting with external/internal infrastructure
    class StoreNotifyToken
      include Dry::Transaction

      step :get_token
      step :store_token

      private

      INPUT_ERROR = 'LINE NOTIFY ACCESS ERROR'
      RESPONSE_ERROR = 'LINE NOTIFY FAILED TO GET TOKEN'

      # :reek:FeatureEnvy
      def get_token(input)
        Failure(INPUT_ERROR) unless input.failure?

        uri = URI('https://notify-bot.line.me/oauth/token')
        header = { 'Content-Type': 'application/x-www-form-urlencoded' }

        data = format_request(input)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true # secure sockets layer, protect sensitive data from modification

        response = https.post(uri, data, header)
        if response.is_a?(Net::HTTPSuccess)
          body = JSON.parse response.body
          Success(user_id: input['state'], access_token: body['access_token'])
        else
          Failure(RESPONSE_ERROR)
        end
      end

      def store_token(input)
        result = Gateway::Api.new(NoFB::App.config)
                             .add_user_notify(input)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts "#{e.inspect}\\n#{e.backtrace}"
        Failure('Cannot add user info about notification right now; please try again later')
      end

      def format_request(input)
        data = {
            'grant_type': 'authorization_code',
            'code': input['code'],
            'redirect_uri': App.config.NOTIFY_REDIRECT_URI,
            'client_id': App.config.NOTIFY_CLIENT_ID,
            'client_secret': App.config.NOTIFY_CLIENT_SECRET
        }
        URI.encode_www_form(data)
      end
    end
  end
end
