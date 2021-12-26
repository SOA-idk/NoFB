# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Service object interacting with userinfo that linked to LINE user
    class FindUser
      include Dry::Transaction

      step :prepare_input
      step :find_user
      step :reify_user

      private

      def prepare_input(input)
        Success(user_id: input[:user]['sub'],
                user_name: input[:user]['name'],
                user_img: input[:user]['picture'],
                user_email: input[:access_token])
      end

      # :reek:UncommunicativeVariableName
      # :reek:TooManyStatements
      def find_user(input)
        result = Gateway::Api.new(NoFB::App.config)
                             .find_user(input)
        puts 'result of find user'
        puts result
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts "#{e.inspect}\\n#{e.backtrace}"
        Failure('Cannot find user right now; please try again later')
      end

      def reify_user(user_json)
        Representer::User.new(OpenStruct.new)
                              .from_json(user_json)
                              .then { |user| Success(user) }
      rescue StandardError
        Failure('Error in the user -- please try again')
      end
    end
  end
end
