# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Show the group of given group_id
    class ShowOneGroup
      include Dry::Transaction

      step :get_all_groups
      step :reify_list
      step :extract_specific_group

      private

      def save_input(group_id)
        @group_id = group_id
      end

      def get_all_groups(group_id)
        save_input(group_id)
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

      def extract_specific_group(groups)
        results = groups.groups.select do |group|
          group if group.group_id == @group_id
        end
        Success(results[0]) # it should be only one in `results` array
      rescue StandardError
        Failure('Having trouble of extracting the group')
      end
    end
  end
end
