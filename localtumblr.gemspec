# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'localtumblr/version'

Gem::Specification.new do |spec|
  spec.name          = "localtumblr"
  spec.version       = Localtumblr::VERSION
  spec.authors       = ["Alex Melman"]
  spec.email         = ["amelman5@gmail.com"]
  spec.description   = %q{Tumblr theme previews on your local environment}
  spec.summary       = %q{A local environment on which Tumblr themes can be run.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "oj"
  spec.add_development_dependency "nokogiri"
  # spec.add_development_dependency "pry"

  spec.add_dependency "activesupport"
  spec.add_dependency "faraday"
  spec.add_dependency "multi_json"
  spec.add_dependency "slop"
end
