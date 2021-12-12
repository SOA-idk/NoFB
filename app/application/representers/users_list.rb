# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'openstruct_with_links'
require_relative 'user'

module NoFB
  module Representer
    # Represents list of projects for API output
    class UsersList < Roar::Decorator
      include Roar::JSON

      collection :users, extend: Representer::User,
                         class: Representer::OpenStructWithLinks
    end
  end
end
