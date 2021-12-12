# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Delete Subscriptions
    class UpdateSubscription
      include Dry::Transaction

      step :update_query

      private

      # :reek:FeatureEnvy
      def update_query(input)
        sub = Entity::Subscribes.new(user_id: input[:user_id],
                                     group_id: input[:group_id],
                                     word: input[:word])
        Repository::For.klass(Entity::Subscribes)
                       .db_update_or_create(sub)
        Success('Successfully update subscribed words !')
      rescue StandardError
        Failure('Having trouble accessing Database')
      end
    end
  end
end
