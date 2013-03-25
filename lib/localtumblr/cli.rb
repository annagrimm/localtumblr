require 'slop'
require 'localtumblr'

module Localtumblr
  class CLI
    class << self
      def start(*args)
        # Parse command line options
        opts = set_opts(args)
        if !opts['base-hostname'].nil? && !opts['consumer-key'].nil?
          post_opts = {}
          if !opts['post-id'].blank?
            post_opts[:id] = opts['post-id']
          else
            post_opts[:tag] = opts['post-tag'] unless opts['post-tag'].nil?
            post_opts[:type] = opts['post-type'] unless opts['post-type'].nil?
          end

          posts = Localtumblr::Post.from_blog(opts['base-hostname'], opts['consumer-key'], post_opts)
        end

        # Check if a source template file has been passed in (required)
        if opts[:file].blank?
          puts opts
          exit
        end

        # Begin setting template options
        template_options = {
          debug: opts[:debug]
        }

        # Set index or permalink page
        page = !opts['post-id'].blank? ? :permalink : :index
        template_options[:page] = page

        # Create a template from source file
        template = Localtumblr::Template.from_file(opts[:file], template_options)
        # Set posts for the template
        template.posts = posts unless posts.nil?
        # Parse template
        template.parse

        # Output parsed template to file or string
        output = opts[:output]
        if output.nil?
          puts template.to_s
        else
          template.to_file(output)
        end
      end

      def set_opts(args)
        opts = Slop.parse args, help: true do
          banner 'Usage: localtumblr [options]'

          on :o, :output=, "Set the output"
          on :f, :file=, "The Tumblr template file to parse"
          on :b, 'base-hostname=', "The host name for your Tumblr blog (ex: \"blog.tumblr.com\")"
          on :k, 'consumer-key=', "The consumer key for the Tumblr application linked to your blog"
          on :t, 'post-tag=', "Import posts with a specified tag"
          on :T, 'post-type=', "Import posts with a specified type"
          on :p, 'post-id=', "Imports the post specified by an ID and sets the page as the post's permalink page"
          on :d, 'debug', "Enable debug mode"
          on :v, :version, "Display the Localtumblr version" do
            puts "Localtumblr version #{Localtumblr::VERSION} on Ruby #{RUBY_VERSION}"
            exit
          end
        end

        # exit if opts.help?
      end
    end
  end
end