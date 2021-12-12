# frozen_string_literal: true

require 'dry-validation'

module NoFB
  module Forms
    # dealing with routing params
    class NewSubscription < Dry::Validation::Contract
      URL_REGEX = %r{(https?)://(www.)?facebook\.com}

      params do
        required(:fb_url).filled(:string)
        required(:subscribed_word).filled(:string)
      end

      rule(:fb_url) do
        key.failure('is an invalid address for a facebook group.') unless URL_REGEX.match?(value)
      end
    end
  end
end
