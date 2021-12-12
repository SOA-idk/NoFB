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

      def projects_list(list)
        @request.projects_list(list)
      end

      def add_project(owner_name, project_name)
        @request.add_project(owner_name, project_name)
      end

      # Gets appraisal of a project folder rom API
      # - req: ProjectRequestPath
      #        with #owner_name, #project_name, #folder_name, #project_fullname
      def appraise(req)
        @request.get_appraisal(req)
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
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def projects_list(list)
          call_api('get', ['projects'],
                   'list' => Value::WatchedList.to_encoded(list))
        end

        def add_project(owner_name, project_name)
          call_api('post', ['projects', owner_name, project_name])
        end

        def get_appraisal(req)
          call_api('get', ['projects',
                           req.owner_name, req.project_name, req.folder_name])
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

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
                .then { |str| str ? "?#{str}" : '' }
        end

        # rubocop:disable Metrics/MethodLength
        def call_api(method, resources = [], params = {}, body = nil) 
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          puts "calling #{url}"
          if method == 'get'
            HTTP.headers('Accept' => 'application/json').send(method, url)
                .then { |http_response| Response.new(http_response) }
          else # post
            HTTP.headers('Accept' => 'application/json').post(url, form: body)
                .then { |http_response| Response.new(http_response) }
          end
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
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
