# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Delete Subscriptions
    class DeleteSubscriptions
      include Dry::Transaction

      step :create_query

      private

      # :reek:NilCheck
      def create_query(input)
        query = Database::SubscribesOrm[input]
        unless query.nil?
          query.delete
          Success("#{input[:user_id]}/#{input[:group_id]}")
        end
      rescue StandardError
        Failure('Having trouble accessing Database')
      end
    end
  end
end
