# frozen_string_literal: true

require 'dry/transaction'

module NoFB
  module Service
    # Show Posts
    class ShowPosts
      include Dry::Transaction

      step :get_all_posts
      step :reify_list
      step :extract_specific_user

      private

      def save_input(group_id)
        @group_id = group_id
      end

      def get_all_posts(group_id)
        save_input(group_id)
        Gateway::Api.new(NoFB::App.config)
                    .posts_list
                    .then do |result|
                      result.success? ? Success(result.payload) : Failure(result.message)
                    end
      rescue StandardError
        Failure('Could not access our API')
      end

      def reify_list(posts_json)
        Representer::PostsList.new(OpenStruct.new)
                              .from_json(posts_json)
                              .then { |posts| Success(posts) }
      rescue StandardError
        Failure('Could not parse response from API')
      end

      def extract_specific_user(posts)
        results = posts.posts.map do |post|
          post if post.group_id == @group_id
        end
        Success(results)
      rescue StandardError
        Failure('Having trouble of extracting the group')
      end
    end
  end
end
