# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'user'

module NoFB
  module Representer
    # Represents list of projects for API output
    class PostsList < Roar::Decorator
      include Roar::JSON

      collection :posts, extend: Representer::Post,
                         class: Representer::OpenStructWithLinks
    end
  end
end
