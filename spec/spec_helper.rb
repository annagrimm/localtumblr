require "localtumblr"
require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  # c.debug_logger = File.open('vcr_log.txt', 'w')
end

RSpec.configure do |config|
  # Expectation settings
  config.expect_with :rspec do |c|
    # Use expect syntax only
    c.syntax = :expect

    # Use should syntax only
    # c.syntax = :should

    # Use both expect and should syntax
    # c.syntax = [:should, :expect]
  end

  # Use color in STDOUT
  config.color_enabled = true

  # In RSpec 3 this will no longer be necessary.
  config.treat_symbols_as_metadata_keys_with_true_values = true
end