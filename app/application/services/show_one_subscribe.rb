# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Show Subscriptions
    class ShowOneSubscribe
      include Dry::Transaction

      step :get_all_subscription
      step :reify_list
      step :extract_specific_user_group

      private

      def save_input(input)
        @user_id = input[:user_id]
        @group_id = input[:group_id]
      end

      def get_all_subscription(input)
        save_input(input)
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

      def extract_specific_user_group(subscriptions)
        # puts @user_id, @group_id
        results = subscriptions.subscribes.select do |subscription|
          subscription if subscription.user_id == @user_id && subscription.group_id == @group_id
        end
        Success(results[0]) # it should be only one in `results` array
      rescue StandardError
        Failure('Having trouble of extracting the user')
      end
    end
  end
end
