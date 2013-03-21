require 'ostruct'

module Localtumblr
  class Config < OpenStruct
    attr_accessor :cli_output
    attr_accessor :template_file
    attr_accessor :tumblr_post_limit
    attr_accessor :tumblr_post_type
    attr_accessor :tumblr_post_tag
  end
end