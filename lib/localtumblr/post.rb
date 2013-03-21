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

    def self.from_blog(hostname, consumer_key, opts={})
      #conn = Faraday.new(url: 'http://api.tumblr.com') do |faraday|
      #  faraday.response :net_http
      #end
      posts = []
      req_opts = {
        api_key: consumer_key
      }
      req_opts[:type] = opts[:type] if opts.key?(:type)
      req_opts[:tag] = opts[:tag] if opts.key?(:tag)
      response = Faraday.get "http://api.tumblr.com/v2/blog/#{hostname}/posts", req_opts
      puts response.to_hash
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