# frozen_string_literal: true

require_relative 'list_request'
require 'http'

module NoFB
  module Gateway
    # Infrastructure to call CodePraise API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def subscription_list
        @request.get_subscription_list
      end

      def add_subscribes(input)
        @request.add_subscribes(input)
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

        def get_subscription_list
          call_api('get', ['subscribes'],
                   'access_key' => '123')
        end

        def add_subscribes(input)
          call_api('post',
                   ['subscribes'],
                   { 'access_key' => '123' },
                   input)
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
        def call_api(method, resources = [], params = {}, body = nil)
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          puts "calling #{url}"
          header = HTTP.headers('Accept' => 'application/json')
          if method == 'get'
            header.send(method, url)
                  .then { |http_response| Response.new(http_response) }
          else # post
            header.post(url, form: body)
                  .then { |http_response| Response.new(http_response) }
          end
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
        # rubocop:enable Metrics/MethodLength
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
          payload['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
