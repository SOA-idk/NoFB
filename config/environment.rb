# frozen_string_literal: true

require 'roda'
require 'yaml'
require 'figaro'
require 'delegate' # flash due to bug in rack < 2.3.0

module NoFB
  # Configuration for the App
  class App < Roda
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config() = Figaro.env

      use Rack::Session::Cookie, secrets: config.SESSION_SECRET

      configure :development, :test, :app_test do
        require 'pry'; # for breakpoints
      end
    end
  end
end
