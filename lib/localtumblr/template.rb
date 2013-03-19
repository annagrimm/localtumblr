require 'active_support/core_ext/string'

module Localtumblr
  class Template # extend self
    attr_accessor :source

    def self.from_file(filename)
      source = ''
      File.open(filename, "r") do |f|
        source = f.read
      end
      self.new(source)
    end

    def initialize(template, blocks={}, variables={})
      @source = template

      @tumblr_variables = {}
      @tumblr_variables[:title] = "The Title" # args[:title]
      @tumblr_variables[:tag] = "sports"

      @tumblr_blocks = {
        index_page: true,
        tag_page:   true # false
      }
    end

    def parse(*args)
      source = args.none? ? @source : args[1]
      template = source

      r = /(?<block>\{block:(?<block_name>\w+)\}(?<block_content>.*)\{\/block:\k<block_name>\})|(?<variable>\{(?<variable_name>\w[\w\d-]+)\})/m
      source.scan(r) do |block, block_name, block_content, variable, variable_name|
        if !block.nil?
          val = ''
          case block_name
          when 'Posts'
            posts = [] # Get posts by tag, page, etc.
            posts.each do |post|
              val += parse(block_name, block_content)
            end
          else
            block_key = block_name.underscore.to_sym
            if @tumblr_blocks.key?(block_key) && @tumblr_blocks[block_key]
              val = parse(block_name, block_content)
            end
          end
          template = template.gsub(block, val)
        else
          val = ''
          if @tumblr_variables.key?(variable_name.underscore.to_sym)
            val = @tumblr_variables[variable_name.underscore.to_sym]
          end
          template = template.gsub(variable, val)
        end
      end

      template
    end

    protected
    def open_block(block)
      parse(block)
    end
  end
end
