# frozen_string_literal: true

require 'redis'

module NoFB
  module Cache
    # client class for redis only...?!
    class Client
      def initialize(config)
        @redis = Redis.new(url: config.REDISCLOUD_URL)
      end

      def keys
        @redis.keys
      end

      def wipe
        keys.each { |key| @redis.del(key) }
      end
    end
  end
end
