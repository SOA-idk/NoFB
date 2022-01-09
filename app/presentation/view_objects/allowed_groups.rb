# frozen_string_literal: true

require_relative 'group'

module View
  # A list with lots of group
  class AllowedGroups
    def initialize(groups)
      @groups = groups.map { |group| Group.new(group) }
    end

    def each(&block)
      @groups.each(&block)
    end

    def any?
      @groups.any?
    end
  end
end
