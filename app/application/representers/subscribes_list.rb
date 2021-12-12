# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'subscribe'

module NoFB
  module Representer
    # Represents list of projects for API output
    class SubscribesList < Roar::Decorator
      include Roar::JSON

      collection :subscribes, extend: Representer::Subscribe, class: Representer::OpenStructWithLinks
    end
  end
end
