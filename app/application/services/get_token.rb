# frozen_string_literal: true

require 'dry/transaction'
require 'uri'
require 'net/http'
require 'jwt'

module NoFB
  module Service
    # Service object interacting with external/internal infrastructure
    class GetToken
      include Dry::Transaction

      step :get_token

      private

      # :reek:FeatureEnvy
      def get_token(input)
        uri = URI('https://api.line.me/oauth2/v2.1/token')
        header = { 'Content-Type': 'application/x-www-form-urlencoded' }
        if input.success?
          data = {
            'grant_type': 'authorization_code',
            'code': input['code'],
            'redirect_uri': App.config.LINE_REDIRECT_URI,
            'client_id': App.config.LINE_CLIENT_ID,
            'client_secret': App.config.LINE_CLIENT_SECRET
          }
          data = URI.encode_www_form(data)

          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true

          response = https.post(uri, data, header)
          if response.is_a?(Net::HTTPSuccess)
            body = JSON.parse response.body

            # get userId which is encoded by json web tokens
            decoded_token = JWT.decode body['id_token'], nil, false
          end
          Success(access_token: body['access_token'], user: decoded_token[0])
        else
          Failure('LINE LOGIN ERROR')
        end
      end
    end
  end
end
