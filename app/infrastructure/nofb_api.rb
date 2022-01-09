# frozen_string_literal: true

require_relative 'list_request'
require 'http'

module NoFB
  module Gateway
    # Infrastructure to call NoFB API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def add_user(input)
        @request.add_user(input)
      end

      def find_user(input)
        @request.find_user(input)
      end

      def add_user_notify(input)
        @request.add_user_notify(input)
      end

      def find_user_notify(input)
        @request.find_user_notify(input)
      end

      def alive?
        @request.get_root.success?
      end

      def subscription_list
        @request.get_subscription_list
      end

      def find_subscribes(input)
        @request.find_subscribes(input)
      end

      def add_subscribes(input)
        @request.add_subscribes(input)
      end

      def delete_subscribes(input)
        @request.delete_subscribes(input)
      end

      def update_subscribes(input)
        @request.update_subscribes(input)
      end

      def posts_list
        @request.get_posts_list
      end

      def groups_list
        @request.get_groups_list
      end

      # HTTP request transmitter
      # rubocop:disable Naming/AccessorMethodName
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{@api_host}/api/v1"
        end

        def get_root
          call_api('get')
        end

        def add_user(input)
          call_api('post', ['users'],
                   { 'access_key' => '123' }, input)
        end

        def add_user_notify(input)
          call_api('post', ['notify'],
                   { 'access_key' => '123' }, input)
        end

        def find_user_notify(input)
          call_api('get', ['notify', input[:user_id]],
                   { 'access_key' => '123' })
        end

        def find_user(input)
          call_api('get', ['users', input[:user_id]], { 'access_key' => '123' })
        end

        def get_subscription_list
          call_api('get', ['subscribes'],
                   'access_key' => '123')
        end

        def find_subscribes(input)
          call_api('get', ['subscribes', input[:user_id]], { 'access_key' => '123' })
        end

        def add_subscribes(input)
          call_api('post',
                   ['subscribes'],
                   { 'access_key' => '123' },
                   input)
        end

        # :reek:FeatureEnvy
        def delete_subscribes(input)
          call_api('delete', ['subscribes', input[:user_id], input[:group_id]], 'access_key' => '123')
        end

        # :reek:FeatureEnvy
        def update_subscribes(input)
          call_api('patch',
                   ['subscribes', input[:user_id], input[:group_id]],
                   { 'access_key' => '123' },
                   { subscribed_word: input[:word] })
        end

        def get_posts_list
          call_api('get', ['posts'],
                   'access_key' => '123')
        end

        def get_groups_list
          call_api('get', ['groups'],
                   'access_key' => '123')
        end

        private

        # :reek:UtilityFunction
        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
                .then { |str| str ? "?#{str}" : '' }
        end

        # rubocop:disable Metrics/MethodLength
        # :reek:TooManyStatements
        # :reek:LongParameterList
        # rubocop:disable Metrics/AbcSize
        def call_api(method, resources = [], params = {}, body = nil)
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          header = HTTP.headers('Accept' => 'application/json')
          
          case method
          when 'get', 'delete'
            header.send(method, url)
                  .then { |http_response| Response.new(http_response) }
          when 'patch'
            header.patch(url, form: body)
                  .then { |http_response| Response.new(http_response) }
          else # post
            header.post(url, form: body)
                  .then { |http_response| Response.new(http_response) }
          end
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize
      end
      # rubocop:enable Naming/AccessorMethodName

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        # this is uesless descriptive comment
        NotFound = Class.new(StandardError)

        SUCCESS_CODES = (200..299)

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def message
          json['message']
        end

        def payload
          body.to_s
        end

        def json
          JSON.parse(payload)
        end
      end
    end
  end
end
