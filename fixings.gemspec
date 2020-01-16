# frozen_string_literal: true
require_relative "lib/fixings/version"

Gem::Specification.new do |spec|
  spec.name = "fixings"
  spec.version = Fixings::VERSION
  spec.authors = ["Harry Brundage"]
  spec.email = ["harry.brundage@gmail.com"]

  spec.summary = "Easy rails setup with infrastructure and a bunch of handy correctness pieces"
  spec.homepage = "https://github.com/airhorns/fixings"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/airhorns/fixings"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "active_record_query_trace"
  spec.add_runtime_dependency "annotate"
  spec.add_runtime_dependency "ar_transaction_changes"
  spec.add_runtime_dependency "bcrypt"
  spec.add_runtime_dependency "flipper"
  spec.add_runtime_dependency "flipper-active_record"
  spec.add_runtime_dependency "flipper-active_support_cache_store"
  spec.add_runtime_dependency "flipper-ui"
  spec.add_runtime_dependency "health_check"
  spec.add_runtime_dependency "letter_opener"
  spec.add_runtime_dependency "letter_opener_web"
  spec.add_runtime_dependency "marginalia"
  spec.add_runtime_dependency "oj"
  spec.add_runtime_dependency "rack-cors"
  spec.add_runtime_dependency "rails", "~> 6.0"
  spec.add_runtime_dependency "rails-middleware-extensions"
  spec.add_runtime_dependency "rails_semantic_logger"

  spec.add_runtime_dependency "bullet"
  spec.add_runtime_dependency "rubocop"
  spec.add_runtime_dependency "rubocop-performance"
  spec.add_runtime_dependency "rubocop-rails"
  spec.add_runtime_dependency "rufo"

  spec.add_runtime_dependency "minitest-ci"
  spec.add_runtime_dependency "minitest-snapshots"
  spec.add_runtime_dependency "mocha"
  spec.add_runtime_dependency "timecop"
  spec.add_runtime_dependency "vcr"
  spec.add_runtime_dependency "webmock"

  spec.add_runtime_dependency "sentry-raven"
end
