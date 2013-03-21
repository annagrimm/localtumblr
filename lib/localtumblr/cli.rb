require 'slop'
require 'localtumblr'

module Localtumblr
  class CLI
    class << self
      def start(*args)
        opts = set_opts #(args)
        if !opts['tumblr-base-hostname'].nil? && !opts['tumblr-consumer-key'].nil?
          post_opts = {}
          post_opts[:tag] = opts['tumblr-post-tag'] unless opts['tumblr-post-tag'].nil?
          post_opts[:type] = opts['tumblr-post-type'] unless opts['tumblr-post-type'].nil?
          posts = Localtumblr::Post.from_blog(opts['tumblr-base-hostname'], opts['tumblr-consumer-key'], post_opts)
          puts "POSTS: #{posts}"
        end
        output = opts[:output]
        template = Localtumblr::Template.from_file(opts[:file])
        template.posts = posts unless posts.nil?
        puts template.parse if output.nil?
      end

      def set_opts #(args)
        opts = Slop.parse ARGV, help: true do
          banner 'Usage: localtumblr [options]'

          on :o, :output=, "Set the output"
          on :f, :file=, "The Tumblr template file to parse"
          on :H, 'tumblr-base-hostname=', "The host name for your Tumblr blog (ex: \"blog.tumblr.com\")"
          on :k, 'tumblr-consumer-key=', "The consumer key for the Tumblr application linked to your blog"
          on :t, 'tumblr-post-tag=', "Import posts with a specified tag"
          on :T, 'tumblr-post-type=', "Import posts with a specified type"
          on :v, :version, "Display the Localtumblr version" do
            puts "Localtumblr version #{Localtumblr::VERSION} on Ruby #{RUBY_VERSION}"
            exit
          end

          # last_arg = ARGV.last
          # Localtumblr::CLI.template = Localtumblr::Template.from_file(last_arg)
        end

        # exit if opts.help?
      end
    end
  end
end