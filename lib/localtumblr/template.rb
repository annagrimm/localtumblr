require 'active_support/core_ext/string'
require 'pry'
module Localtumblr
  class Template # extend self
    attr_accessor :source
    attr_accessor :posts

    def self.from_file(filename, args={})
      source = ''
      File.open(filename, "r") do |f|
        source = f.read
      end
      Template.new(source, args)
    end

    def initialize(template, args={})
      @source = template

      @debug = args.key?(:debug) ? args[:debug] : false

      @tumblr_variables = {}
      @tumblr_variables[:title] = "The Title" # args[:title]
      @tumblr_variables[:tag] = "sports"

      @tumblr_blocks = {
        index_page: true,
        tag_page:   true # false
      }

      @post_variables = {}

      @indent_width = 4
      @indent_count = 0
      @indent = ''
    end

    def puts_with_indent(str)
      puts @indent + str.gsub("\n", "\n#{@indent}") if @debug
    end

    def inc_indent
      if @debug
        @indent_count += 1
        @indent = ' ' * (@indent_width * @indent_count)
      end
    end

    def dec_indent
      if @debug
        @indent_count -= 1 if @indent_count > 0
        @indent = ' ' * (@indent_width * @indent_count)
      end
    end

    def parse(*args)
      source = args.none? ? @source : args[1]
      template = source.dup

      post_data = args[2] if args.count >= 3

      r = /(?<block>\{block:(?<block_name>\w+)\}(?<block_content>.*?)\{\/block:\k<block_name>\})|(?<variable>\{(?<variable_name>\w[\w\d-]+)\})/m
      i = 0
      source.scan(r) do |block, block_name, block_content, variable, variable_name|
        i += 1
        if !block.nil?
          val = ''
          puts_with_indent "Enter block: #{block_name}"
          inc_indent

          case block_name
          when 'Posts'
            j = 0

            @posts.each do |post|
              puts_with_indent "Enter post ##{j}"
              inc_indent
              j += 1

              @post_variables = {}
              post.each do |k, v|
                case k
                when :id
                  @post_variables[:post_id] = v.to_s
                when :timestamp
                  @post_variables[:timestamp] = v
                  @post_variables[:date] = Time.at(v)
                else
                  @post_variables[k] = v
                end
              end
              puts @post_variables
              val += parse(block_name, block_content, post)

              dec_indent
              puts_with_indent "Exit post ##{j}"
            end
          else
            block_key = block_name.underscore.to_sym
            # TODO: Fix this. Blocks must be enabled/disabled based on settings.
            #if @tumblr_blocks.key?(block_key) && @tumblr_blocks[block_key]
              val = parse(block_name, block_content)
            #end
          end
          rs = /(?<block>\{block:(?<block_name>\w+)\}.*?\{\/block:\k<block_name>\})/m
          template = template.sub(rs, val)

          dec_indent
          puts_with_indent "Exit block: #{block_name}"
        else
          puts_with_indent "Variable: #{variable_name} / #{variable_name.underscore.to_sym} = #{@post_variables[variable_name.underscore.to_sym]}"
          val = ''
          if @post_variables.key?(variable_name.underscore.to_sym)
            val = @post_variables[variable_name.underscore.to_sym]
          elsif @tumblr_variables.key?(variable_name.underscore.to_sym)
            val = @tumblr_variables[variable_name.underscore.to_sym]
          end
          template = template.sub(variable, val)
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
