# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Show the all the allowed group
    # :reek:InstanceVariableAssumption
    class ShowGroups
      include Dry::Transaction

      step :get_all_groups
      step :reify_list

      private

      def get_all_groups(_input)
        Gateway::Api.new(NoFB::App.config)
                    .groups_list
                    .then do |result|
                      result.success? ? Success(result.payload) : Failure(result.message)
                    end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(groups_json)
        Representer::GroupsList.new(OpenStruct.new)
                               .from_json(groups_json)
                               .then { |groups| Success(groups) }
      rescue StandardError
        Failure('Could not parse response from API')
      end
    end
  end
end
