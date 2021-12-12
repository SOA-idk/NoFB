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

      def validate_input(input)
        if input.success?
          Success(user_id: '123', fb_url: input[:fb_url], subscribed_word: input[:subscribed_word])
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def send_post(input)
        result = Gateway::Api.new(NoFB::App.config)
                             .add_subscribes(input)
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError => e
        puts e.inspect + '\n' + e.backtrace
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
