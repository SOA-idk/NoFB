# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Service object interacting with external/internal infrastructure
    class AddSubscriptions
      include Dry::Transaction

      step :validate_input
      step :send_post
      step :reify_subscribe

      private

      # :reek:FeatureEnvy
      def validate_input(input)
        if input[:data].success?
          fb_url = input[:data][:fb_url].split('|')[0]
          Success(user_id: input[:user_id], fb_url: fb_url,
                  subscribed_word: input[:data][:subscribed_word])
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      # :reek:UncommunicativeVariableName
      # :reek:TooManyStatements
      def send_post(input)
        result = Gateway::Api.new(NoFB::App.config)
                             .add_subscribes(input)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts "#{e.inspect}\\n#{e.backtrace}"
        Failure('Cannot add subscribe right now; please try again later')
      end

      def reify_subscribe(subscribe_json)
        Representer::Subscribe.new(OpenStruct.new)
                              .from_json(subscribe_json)
                              .then { |subscribe| Success(subscribe) }
      rescue StandardError
        Failure('Error in the subscribe -- please try again')
      end
    end
  end
end
