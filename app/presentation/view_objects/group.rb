# frozen_string_literal: true

module View
  # Facebook Group which is linked with user_id
  class Group
    attr_reader :index

    def initialize(group, user_id = nil, index = nil)
      @group = group
      @index = index
      @user_id = user_id
    end

    def group_id
      @group.group_id
    end

    def group_name
      @group.group_name
    end

    def word
      @group.word
    end

    def full_path
      "#{@user_id}/#{@group.group_id}"
    end

    def group_url
      "https://www.facebook.com/groups/#{@group.group_id}"
    end

    def group_value
      "#{group_url}|#{group_name}"
    end
  end
end
