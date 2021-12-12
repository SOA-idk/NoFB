# frozen_string_literal: true

require 'http'
require 'yaml'

config = YAML.safe_load(File.read('./config/secrets.yml'))['development']['FB_TOKEN']

def fb_api_path(group_id, config)
  "https://graph.facebook.com/#{group_id}?access_token=#{config}"
end

# :reek:UtilityFunction
def call_fb_url(_config, url)
  # HTTP.headers(
  #   'Content-type' => 'application/json; charset=UTF-8',
  #   'Authorization' => "Token token=#{config['FB_TOKEN']}"
  #   ).get(url)
  HTTP.get(url)
end

fb_response = {}
fb_results = {}

# Happy project request
project_url = fb_api_path('302165911402681/feed', config)
fb_response[project_url] = call_fb_url(config, project_url)

puts fb_response[project_url]
project = JSON.parse(fb_response[project_url]) # not sure

fb_results['data'] = project['data']

# Bad project request
# bad_project_url = fb_api_path('302165911402682/feed', config)
# fb_response[bad_project_url] = call_fb_url(config, bad_project_url)
# JSON.parse(fb_response[bad_project_url])

File.write('./spec/fixtures/nofb_results.yml', fb_results.to_yaml)
