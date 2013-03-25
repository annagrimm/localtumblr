require 'active_support/core_ext/string'
require 'faraday'
require 'multi_json'

module Localtumblr
  class Post < Hash
    def initialize(attrs)
      attrs.each do |k, v|
        self[k] = v
      end
    end

    def self.from_blog(hostname, consumer_key, opts={})
      posts = []
      req_opts = {
        api_key: consumer_key
      }
      if opts.key?(:id)
        req_opts[:id] = opts[:id]
      else
        req_opts[:type] = opts[:type] if opts.key?(:type)
        req_opts[:tag] = opts[:tag] if opts.key?(:tag)
      end
      response = Faraday.get "http://api.tumblr.com/v2/blog/#{hostname}/posts", req_opts
      if response.status == 200
        parse_response(response.body).each do |post|
          posts << (p = Post.new(post))
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