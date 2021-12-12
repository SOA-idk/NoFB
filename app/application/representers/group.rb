# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module NoFB
  module Representer
    #  Represents Group information for API output
    class Group < Roar::Decorator
      include Roar::JSON

      property :group_name
      property :group_id
      property :updated_at
      property :created_at
    end
  end
end
