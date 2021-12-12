# frozen_string_literal: true

module View
  # consruct original posts entities
  # :reek:TooManyInstanceVariables
  class Posts
    attr_reader :group_name, :group_id, :size, :post_list, :posts

    def initialize(group, posts)
      sort_posts = posts.sort_by(&:updated_time).reverse
      @group_name = group.group_name
      @group_id = group.group_id
      @size = sort_posts.length
      @post_list = sort_posts.map(&:post_id)
      @posts = sort_posts
    end
  end
end
