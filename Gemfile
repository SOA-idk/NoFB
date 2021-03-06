# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# CONFIGURATION
gem 'figaro', '~> 1.2'
gem 'rake', '~> 13.0'

# PRESENTATION LAYER
gem 'slim', '~> 4.1'
gem 'multi_json', '~> 1.15'
gem 'roar', '~> 1.1'

# APPLICATION LAYER
# Web Application
gem 'uri'
gem 'jwt'
gem 'puma', '~> 5.5'
gem 'roda', '~> 3.49'
gem 'rack', '~> 2' # 2.3 will fix delegateclass bug
gem 'redis'
gem 'rack-cache'
gem 'redis-rack-cache'

# Controllers and services
gem 'dry-monads', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 5.0'

# TESTING
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'
  gem 'simplecov', '~> 0'

  gem 'page-object', '~> 2.3'
  # not included in DOMAIN Value for app_only
  gem 'watir', '~> 7.0'
  gem 'webdrivers', '~> 5.0'
  gem 'headless', '~> 2.3'
end

group :development do
  gem 'rerun', '~> 0'
end

# DEBUGGING
gem 'pry'

# QUALITY
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end
