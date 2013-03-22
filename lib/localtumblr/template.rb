require 'active_support/core_ext/string'
require 'pry'

module Localtumblr
  class Template
    UNPARSED_TEMPLATE_ERROR_MSG = "Template has not yet been parsed. Use Localtumblr::Template.parse to parse the template."
    UnparsedTemplatedError = Class.new(StandardError)

    attr_accessor :source_template
    attr_reader :parsed_template
    attr_accessor :posts

    def self.from_file(filename, args={})
      source = ''
      File.open(filename, "r") do |f|
        source = f.read
      end
      Template.new(source, args)
    end

    def initialize(template, args={})
      @source_template = template

      @debug = args.key?(:debug) ? args[:debug] : false

      @tumblr_variables = {}
      @tumblr_variables[:title] = "The Title" # args[:title]
      @tumblr_variables[:tag] = "sports"

      @tumblr_blocks = {
        index_page: true,
        tag_page:   true # false
      }

      @post_variables = {}
      @post_photo_alt_sizes = {
        '500' => 4,
        '400' => 3,
        '250' => 2,
        '100' => 1,
        '75' => 0
      }

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
      root = args.none?
      source = root ? @source_template : args[1]
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
              val += parse(block_name, block_content, post)
              @post_variables = {}

              dec_indent
              puts_with_indent "Exit post ##{j}"
              j += 1
            end
          when 'Text', 'Photo', 'Panorama', 'Photoset', 'Quote', 'Link', 'Chat', 'Audio', 'Video', 'Answer'
            if @post_variables.any?
              if @post_variables[:type] == block_name.downcase
                val = parse(block_name, block_content)
              end
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
          if @post_variables.any?
            case variable_name
            when /PhotoURL-(\d{2,3}\w{0,2})/
              # ***** TODO: PHOTO POSTS MUST BE EXPANDED ALSO INTO INDIVIDUAL PHOTOS *****
              # Test on Tumblr to see if entire block is duplicated or just the photo tags.
              if @post_variables[:photos][0][:alt_sizes].count > @post_photo_alt_sizes[$1]
                alt_size = @post_variables[:photos][0][:alt_sizes][0 - (@post_photo_alt_sizes[$1] + 1)]
              else
                alt_size = @post_variables[:photos][0][:alt_sizes].first
              end
              val = alt_size[:url]
            when /Photo(Width|Height)-(\d{3})/
              if @post_variables[:photos][0][:alt_sizes].count > @post_photo_alt_sizes[$2]
                alt_size = @post_variables[:photos][0][:alt_sizes][0 - (@post_photo_alt_sizes[$2] + 1)]
              else
                alt_size = @post_variables[:photos][0][:alt_sizes].first
              end
              val = alt_size[$1.downcase.to_sym].to_s
            when 'PhotoAlt'
              val = @post_variables[:photos][0][:caption]
            end
            if @post_variables.key?(variable_name.underscore.to_sym)
              val = @post_variables[variable_name.underscore.to_sym]
            end
          end
          if @tumblr_variables.key?(variable_name.underscore.to_sym)
            val = @tumblr_variables[variable_name.underscore.to_sym]
          end
          template = template.sub(variable, val)
        end
      end

      if root
        @parsed_template = template
        return self # Make chainable if root
      end
      template
    end
    alias_method :to_html, :parse

    def to_s
      raise UnparsedTemplatedError, UNPARSED_TEMPLATE_ERROR_MSG if @parsed_template.nil?
      @parsed_template
    end

    def to_file(filename)
      raise UnparsedTemplatedError, UNPARSED_TEMPLATE_ERROR_MSG if @parsed_template.nil?
      File.open(filename, 'w') do |f|
        f.puts @parsed_template
      end
    end

    protected
    def open_block(block)
      parse(block)
    end
  end
end
