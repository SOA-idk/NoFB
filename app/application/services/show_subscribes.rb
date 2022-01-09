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

      private

      def save_input(user_id)
        @user_id = user_id
      end

      def get_all_subscription(user_id)
        save_input(user_id)
        Gateway::Api.new(NoFB::App.config)
                    .find_subscribes(user_id: user_id)
                    .then do |result|
                      result.success? ? Success(result.payload) : Failure(result.message)
                    end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(subscriptions_json)
        sub_list = Representer::SubscribesList.new(OpenStruct.new)
                                              .from_json(subscriptions_json)
        # call Api to get group_name
        sub_list['subscribes'].map do |sub|
          group = Gateway::Api.new(NoFB::App.config)
                              .group_name(group_id: sub['group_id'])
                              .then { |result| result.success? ? result.payload : 'Error' }
                              .then { |group_json| Representer::Group.new(OpenStruct.new).from_json(group_json) }
          sub['group_name'] = group['group_name']
        end
        Success(sub_list)
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end
