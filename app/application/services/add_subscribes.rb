# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Service object interacting with external/internal infrastructure
    class AddSubscriptions
      include Dry::Transaction

      step :parse_url
      step :find_subscribes
      step :store_subscribes

      private

      def parse_url(input)
        if input.success?
          user_id = '123'
          group_id = input[:fb_url].downcase.split('/')[-1..][0].strip
          subscribed_word = input[:subscribed_word]
          Success(group_id: group_id, subscribed_word: subscribed_word, user_id: user_id)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def find_subscribes(input)
        if subscribe_in_database(input).nil?
          Success(input)
        else
          Failure('You already subscribe to this group, go to edit it.')
        end
      rescue StandardError
        Failure('Having trouble accessing Database.')
      end

      def store_subscribes(input)
        create_group(input)
        create_subscribes(input)
        subscribes = Entity::Subscribes.new(group_id: input[:group_id],
                                            word: input[:subscribed_word],
                                            user_id: input[:user_id])
        puts 'subscribe'
        Success(subscribes)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure('Having trouble accessing Database.')
      end

      def subscribe_in_database(input)
        Repository::For.klass(Entity::Subscribes).find_id(input[:user_id], input[:group_id])
      end

      def create_group(input)
        Repository::For.klass(Entity::Group)
                       .db_find_or_create(group_id: input[:group_id],
                                          group_name: 'Test1')
      rescue StandardError
        raise "Could't find or create a group"
      end

      def create_subscribes(input)
        Repository::For.klass(Entity::Subscribes)
                       .db_update_or_create(group_id: input[:group_id],
                                            word: input[:subscribed_word],
                                            user_id: input[:user_id])
      rescue StandardError
        raise "Could't find or create subscriptions"
      end
    end
  end
end