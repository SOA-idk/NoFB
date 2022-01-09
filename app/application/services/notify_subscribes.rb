# frozen_string_literal: true

require 'dry/transaction'
require 'uri'
require 'net/http'
require 'jwt'

module NoFB
  module Service
    # Service object interacting with external/internal infrastructure
    class NotifySubscriptions
      include Dry::Transaction

      step :validate_input
      step :notify_user

      private

      INPUT_ERROR = 'LINE NOTIFY ACCESS ERROR'
      RESPONSE_ERROR = 'LINE NOTIFY FAILED TO GET TOKEN'

      def validate_input(input)
        result = get_token(input)
        if input[:data].success? && result.success?
          fb_url = input[:data][:fb_url].split('|')[0]
          group_name = input[:data][:fb_url].split('|')[1]
          Success(user_id: input[:user_id], fb_url: fb_url,
                  group_name: group_name,
                  subscribed_word: input[:data][:subscribed_word],
                  access_token: result.value!['user_access_token'])
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      # :reek:FeatureEnvy
      def notify_user(input)
        uri = URI('https://notify-api.line.me/api/notify')
        header = { 'Authorization' => "Bearer #{input[:access_token]}",
                   'Content-Type' => 'application/x-www-form-urlencoded' }
        data = {
          'message': "你成功訂閱了 [ #{input[:subscribed_word]} ], 如果 [ #{input[:group_name]} ] 一有貼文，就會通知你唷!\n\nSucessfully subscribed to word [ #{input[:subscribed_word]} ]. If there is new post about [ #{input[:subscribed_word]} ] in group [ #{input[:group_name]} ], We will notify you!!"
        }
        data = URI.encode_www_form(data)

        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true # secure sockets layer, protect sensitive data from modification

        response = https.post(uri, data, header)
        if response.is_a?(Net::HTTPSuccess)
          body = JSON.parse response.body
          Success(status: body['status'])
        else
          Failure(RESPONSE_ERROR)
        end
      end

      def get_token(input)
        result = Gateway::Api.new(NoFB::App.config)
                             .find_user_notify(user_id: input[:user_id])
        result.success? ? Success(result.json) : Failure(result.message)
      end
    end
  end
end
