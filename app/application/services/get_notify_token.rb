# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Service object interacting with external/internal infrastructure
    class GetNotifyToken
      include Dry::Transaction

      step :get_token

      private

      def get_token(input)
        result = Gateway::Api.new(NoFB::App.config)
                             .find_user_notify(input)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts "#{e.inspect}\\n#{e.backtrace}"
        Failure('Cannot add user info about notification right now; please try again later')
      end
    end
  end
end
