# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Delete Subscriptions
    class UpdateSubscription
      include Dry::Transaction

      step :call_update
      step :reify_subscribe

      private

      # :reek:UncommunicativeVariableName
      # :reek:TooManyStatements
      def call_update(input)
        result = Gateway::Api.new(NoFB::App.config)
                             .update_subscribes(input)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts "#{e.inspect}\\n#{e.backtrace}"
        Failure('Cannot update subscribe right now; please try again later')
      end

      def reify_subscribe(subscribe_json)
        Representer::SubscribesList.new(OpenStruct.new)
                                   .from_json(subscribe_json)
                                   .then { |subscribe| Success(subscribe) }
      rescue StandardError
        Failure('Error in the subscribe -- please try again')
      end
    end
  end
end
