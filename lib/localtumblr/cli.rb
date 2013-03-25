require 'slop'
require 'localtumblr'

module Localtumblr
  class CLI
    class << self
      def start(*args)
        opts = set_opts(args)
        if !opts['tumblr-base-hostname'].nil? && !opts['tumblr-consumer-key'].nil?
          post_opts = {}
          post_opts[:tag] = opts['tumblr-post-tag'] unless opts['tumblr-post-tag'].nil?
          post_opts[:type] = opts['tumblr-post-type'] unless opts['tumblr-post-type'].nil?
          posts = Localtumblr::Post.from_blog(opts['tumblr-base-hostname'], opts['tumblr-consumer-key'], post_opts)
        end
        if opts[:file].blank?
          puts opts
          exit
        end

        output = opts[:output]
        debug = opts[:debug]
        template = Localtumblr::Template.from_file(opts[:file], :debug => debug)
        template.posts = posts unless posts.nil?
        template.parse
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
          on :b, 'tumblr-base-hostname=', "The host name for your Tumblr blog (ex: \"blog.tumblr.com\")"
          on :k, 'tumblr-consumer-key=', "The consumer key for the Tumblr application linked to your blog"
          on :t, 'tumblr-post-tag=', "Import posts with a specified tag"
          on :T, 'tumblr-post-type=', "Import posts with a specified type"
          on :p, 'tumblr-post-id=', "Imports the post specified by an ID and sets the page as the post's permalink page"
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