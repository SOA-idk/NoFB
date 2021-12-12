# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../../init'

GROUP_ID = '302165911402681'
# CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
# ACCESS_TOKEN = CONFIG['FB_TOKEN']
ACCESS_TOKEN = NoFB::App.config.FB_TOKEN
CORRECT = YAML.safe_load(File.read('spec/fixtures/nofb_results.yml'))

# CASSETTES_FOLDER = 'spec/fixtures/cassettes'
# CASSETTE_FILE = 'Nofb_api'

# Helper method for acceptance tests

# :reek:UtilityFunction
def homepage
  NoFB::App.config.APP_HOST
end
