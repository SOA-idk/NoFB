# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module NoFB
  # Web App
  # rubocop:disable Metrics/ClassLength
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'confirm.js'
    plugin :halt
    plugin :flash
    plugin :all_verbs # recognizes HTTP verbs beyond GET/POST (e.g., DELETE)

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    # rubocop:disable Metrics/BlockLength
    route do |routing|
      routing.assets # load CSS, JS
      routing.public # make GET public/images/

      # GET /
      routing.root do
        session[:watching] ||= []
        view 'home' # , locals: { posts: posts }
      end

      routing.on 'add' do
        routing.is do
          # GET /add/
          routing.get do
            view 'add'
          end
          # POST /add/
          routing.post do
            # user_id = '123'
            input = Forms::NewSubscription.new.call(routing.params)
            subscription_made = Service::AddSubscriptions.new.call(input)

            if subscription_made.failure?
              flash[:error] = subscription_made.failure
              routing.redirect 'user'
            end

            sub = subscription_made.value!
            session[:watching].insert(0, "#{sub.user_id}/#{sub.group_id}").uniq!
            flash[:notice] = 'Successfully subscribe to specific word(s).'

            routing.redirect 'user'
          end
        end
      end

      # show the posts of the given group_id
      routing.on 'group' do
        routing.on String do |group_id|
          # puts "fb_token: #{App.config.FB_TOKEN}"
          # puts "last / group_id: #{group_id}\n"
          # GET /group/group_id
          routing.get do
            result = Service::ShowPosts.new.call(group_id)

            if result.failure?
              flash[:error] = result.failure
              posts = nil
            else
              posts = result.value!
            end

            result_group = Service::ShowOneGroup.new.call(group_id)
            if result_group.failure?
              flash[:error] = result_group.failure
              group = nil
            else
              group = result_group.value!
            end

            viewable_posts = View::Posts.new(group, posts)
            view 'posts', locals: { posts: viewable_posts }
          end
        end
      end

      routing.on 'user' do
        # /user request
        routing.is do
          # GET /user request
          routing.get do
            user_id = '123'
            result = Service::ShowSubscriptions.new.call(user_id)

            if result.failure?
              flash[:error] = result.failure
              viewable_groups = View::GroupsList.new([], 'user')
            else
              group = result.value!
              # puts group
              flash.now[:notice] = 'Start to subscribe to a word!!' if group.none?
              viewable_groups = View::GroupsList.new(group, 'user')
            end
            view 'user', locals: { groups: viewable_groups }
          end
        end

        # DELETE /user/groupId request
        routing.on String do |group_id|
          routing.delete do
            user_id = '123'
            delete_sub = Service::DeleteSubscriptions.new.call(group_id: group_id, user_id: user_id)

            if delete_sub.failure?
              flash[:error] = 'Having trouble accessing Database'
              routing.redirect '/user'
            end

            delete_path = delete_sub.value!
            session[:watching].delete(delete_path)
            flash[:notice] = 'Successfully unsubscribe !'

            routing.redirect '/user'
          end

          # GET /user/groupId
          routing.get do
            user_id = '123'
            result = Service::ShowOneSubscribe.new.call(user_id: user_id, group_id: group_id)

            if result.failure?
              flash[:error] = result.failure
              viewable_subscribes = View::Subscribes.new([])
            else
              subscribes = result.value!
              viewable_subscribes = View::Subscribes.new(subscribes)
            end
            view 'subscribe', locals: { subscribes: viewable_subscribes }
          end

          # UPDATE /user/groupId
          routing.patch do
            user_id = '123'
            update_request = Forms::UpdateSubscription.new.call(routing.params)
            update_made = Service::UpdateSubscription.new.call(user_id: user_id,
                                                               group_id: group_id,
                                                               word: update_request[:subscribed_word])

            if update_made.failure?
              flash[:error] = "Can't update the subscribed word!"
            else
              flash[:notice] = 'Successfully update subscribed words !'
            end

            routing.redirect '/user'
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ClassLength
end
