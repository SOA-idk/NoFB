# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'uri'

module NoFB
  # Web App
  # rubocop:disable Metrics/ClassLength
  # :reek:RepeatedConditional
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'confirm.js'
    plugin :halt
    plugin :flash
    plugin :caching
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

      routing.on 'login' do
        client_id = App.config.LINE_CLIENT_ID
        redirect_uri = App.config.LINE_REDIRECT_URI
        state = SecureRandom.hex(10)
        data = {
          response_type: 'code',
          client_id: client_id,
          redirect_uri: redirect_uri,
          scope: 'profile openid',
          state: state
        }
        query = URI.encode_www_form(data).gsub('+', '%20')
        routing.redirect "https://access.line.me/oauth2/v2.1/authorize?#{query}"
      end

      routing.on 'callback' do
        routing.get do
          puts routing.params
          # assert routing.head['referer'] == 'https://api.line.me/'
          input = Forms::NewToken.new.call(routing.params)
          user_info = Service::GetToken.new.call(input)

          # check whether user is in database already
          user = Service::FindUser.new.call(user_info.value!)

          # the user is not in db
          if user.failure?
            # puts 'user is not in db'
            # puts user.failure
            # # puts ''
            # puts 'user_info:'
            # puts user_info
            new_user = Service::AddUser.new.call(user_info.value!)
            if new_user.failure?
              flash[:notice] = new_user.failure
              routing.redirect 'user/123'
            end
            # puts "there is new user #{new_user} \n"
            user = new_user
            # flash[:notice] = "Hi, #{new_user.value!.user_name}"
            # routing.redirect "user/#{new_user.value!.user_id}"
          end
          session[:user_info] = user.value!
          flash[:notice] = "Hi, #{user.value!.user_name}"
          routing.redirect "user/#{user.value!.user_id}"
        end
      end

      routing.on 'add' do
        routing.is do
          # GET /add/
          routing.get do
            routing.redirect '/' if session[:user_info].user_id.nil?
            view 'add'
          end
          # POST /add/
          routing.post do
            input = Forms::NewSubscription.new.call(routing.params)
            subscription_made = Service::AddSubscriptions.new.call(user_id: session[:user_info].user_id, data: input)

            if subscription_made.failure?
              flash[:error] = subscription_made.failure
              routing.redirect "user/#{session[:user_info].user_id}"
            end

            sub = subscription_made.value!
            session[:watching].insert(0, "#{sub.user_id}/#{sub.group_id}").uniq!
            flash[:notice] = 'Successfully subscribe to specific word(s).'

            routing.redirect "user/#{session[:user_info.user_id]}"
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

            # :reek:RepeatedConditional
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

            response.expires 60, public: true
            view 'posts', locals: { posts: viewable_posts }
          end
        end
      end

      routing.on 'user' do
        # /user request
        routing.on String do |user_id|
          # GET /user/{user_id} request
          routing.is do
            routing.get do
              result = Service::ShowSubscriptions.new.call(user_id)

              if result.failure?
                flash[:error] = result.failure
                viewable_groups = View::GroupsList.new([], session[:user_info])
              else
                group = result.value!
                flash.now[:notice] = 'Start to subscribe to a word!!' if group.nil?
                viewable_groups = View::GroupsList.new(group[:subscribes], session[:user_info])
              end
              view 'user', locals: { groups: viewable_groups }
            end
          end

          # GET /user/{user_id}/{group_id}
          routing.on String do |group_id|
            puts 'routing on user/user_id/groupid'

            # GET /user/{user_id}/{group_id} request
            routing.get do
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

            # DELETE /user/{user_id}/{group_id} request
            routing.delete do
              delete_sub = Service::DeleteSubscriptions.new.call(group_id: group_id, user_id: user_id)

              if delete_sub.failure?
                flash[:error] = 'Having trouble accessing Database'
                routing.redirect "/user/#{user_id}"
              end

              delete_path = delete_sub.value!
              session[:watching].delete(delete_path)
              flash[:notice] = 'Successfully unsubscribe !'

              routing.redirect "/user/#{user_id}"
            end

            # UPDATE /user/{user_id}/{group_id} request
            routing.patch do
              update_request = Forms::UpdateSubscription.new.call(routing.params)
              update_made = Service::UpdateSubscription.new.call(user_id: user_id,
                                                                group_id: group_id,
                                                                word: update_request[:subscribed_word])

              if update_made.failure?
                flash[:error] = "Can't update the subscribed word!"
              else
                flash[:notice] = 'Successfully update subscribed words !'
              end

              routing.redirect "/user/#{user_id}"
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/ClassLength
end
