# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'user'

module NoFB
  module Representer
    # Represents list of projects for API output
    class GroupsList < Roar::Decorator
      include Roar::JSON

      collection :groups, extend: Representer::Group, class: Representer::OpenStructWithLinks
    end
  end
end
