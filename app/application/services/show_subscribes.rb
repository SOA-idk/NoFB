# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Show Subscriptions
    # :reek:InstanceVariableAssumption
    class ShowSubscriptions
      include Dry::Transaction

      step :get_all_subscription
      step :reify_list
      step :extract_specific_user

      private

      def save_input(user_id)
        @user_id = user_id
      end

      def get_all_subscription(user_id)
        save_input(user_id)
        Gateway::Api.new(NoFB::App.config)
                    .subscription_list
                    .then do |result|
                      result.success? ? Success(result.payload) : Failure(result.message)
                    end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(subscriptions_json)
        Representer::SubscribesList.new(OpenStruct.new)
                                   .from_json(subscriptions_json)
                                   .then { |subscriptions| Success(subscriptions) }
      rescue StandardError
        Failure('Could not parse response from API')
      end

      def extract_specific_user(subscriptions)
        # puts @user_id
        results = subscriptions.subscribes.map do |subscription|
          subscription if subscription.user_id == @user_id
        end
        Success(results)
      rescue StandardError
        Failure('Having trouble of extracting the user')
      end
    end
  end
end
