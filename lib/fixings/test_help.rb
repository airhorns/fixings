# frozen_string_literal: true

require "timecop"
require "minitest-ci" if ENV["CI"].present?
require "minitest/snapshots"
require "mocha"
require "webmock"
require "vcr"

require "mocha/minitest"
require "webmock/minitest"

VCR.configure do |config|
  config.cassette_library_dir = Rails.root.join("test", "vcr_cassettes").to_s
  config.allow_http_connections_when_no_cassette = true
  config.hook_into :webmock

  config.filter_sensitive_data("<AUTHORIZATION>") do |interaction|
    interaction.request.headers.key?("Authorization") && interaction.request.headers["Authorization"].first
  end

  config.class_eval do
    attr_accessor :fixings_query_matcher_param_exclusions
  end
  config.fixings_query_matcher_param_exclusions = []

  config.register_request_matcher :less_sensitive_query do |request_a, request_b|
    params_a = Rack::Utils.parse_query(URI(request_a.uri).query)
    params_b = Rack::Utils.parse_query(URI(request_b.uri).query)
    params_a.except(*config.fixings_query_matcher_param_exclusions) == params_b.except(*config.fixings_query_matcher_param_exclusions)
  end
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    ActionMailer::Base.deliveries.clear
    VCR.insert_cassette("#{self.class.name.underscore}/#{name.downcase}", match_requests_on: %i[method host path less_sensitive_query])
  end

  teardown do
    VCR.eject_cassette
  end
end
