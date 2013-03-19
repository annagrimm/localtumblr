require 'active_support/core_ext/string'
require 'faraday'
require 'multi_json'

module Localtumblr
  class Post
    attr_reader :id

    def initialize(args)
      args.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end

    def self.from_blog(hostname, consumer_key)
      #conn = Faraday.new(url: 'http://api.tumblr.com') do |faraday|
      #  faraday.response :net_http
      #end
      response = Faraday.get "http://api.tumblr.com/v2/blog/#{hostname}/posts", { api_key: consumer_key }
      posts = []
      if response.status == 200
        parse_response(response.body).each do |post|
          posts << (p = Post.new(post))
          puts p.id
        end
      end
      posts
    end

    def self.parse_response(response)
      json_response = MultiJson.load(response, symbolize_keys: true)
      posts = json_response[:response][:posts]
    end
  end
end