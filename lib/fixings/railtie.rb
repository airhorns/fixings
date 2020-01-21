# frozen_string_literal: true
require "active_record_query_trace"
require "ar_transaction_changes"
require "health_check"
require "flipper"
require "flipper-active_record"
require "flipper-active_support_cache_store"
require "flipper-ui"
require "marginalia"
require "oj"
require "bcrypt"
require "rails-middleware-extensions"
require "rails_semantic_logger"
require "rack/cors"
require "sentry-raven"

require "fixings/app_release"
require "fixings/silent_log_middleware"

if !Rails.env.production?
  require "annotate"
  require "bullet"
  require "letter_opener"
  require "letter_opener_web"
  require "factory_bot_rails"
end

module Fixings
  class Railtie < Rails::Railtie
    config.app_generators do |g|
      g.factory_bot suffix: "factory"
    end

    rake_tasks do
      load "fixings.rake"
    end

    initializer "fixings.configure_active_record_query_trace" do
      if Rails.env.development?
        ActiveRecordQueryTrace.colorize = :light_purple
        ActiveRecordQueryTrace.enabled = ENV["TRACE_QUERIES"].present?
      end
    end

    initializer "fixings.configure_rack_cors_middleware" do |app|
      app.middleware.insert_before 0, Rack::Cors do
      end
    end

    initializer "fixings.configure_flipper" do |app|
      Flipper.configure do |config|
        config.default do
          database_adapter = Flipper::Adapters::ActiveRecord.new
          adapter = Flipper::Adapters::ActiveSupportCacheStore.new(database_adapter, Rails.cache, expires_in: 5.minutes)
          Flipper.new(adapter)
        end
      end

      app.middleware.use Flipper::Middleware::Memoizer
    end

    initializer "fixings.configure_sentry" do
      Raven.configure do |config|
        config.silence_ready = true
        config.logger = SemanticLogger[Raven]

        if Rails.env.production?
          config.release = AppRelease.current
        end
      end
    end

    initializer "fixings.configure_development_logger" do |app|
      STDOUT.sync = true
      app.config.rails_semantic_logger.semantic = true

      if Rails.env.development?
        # Always log to stdout in development. Rails somehow magically makes this happen for the webserver but not for other processes
        # like the jobs server
        if SemanticLogger.appenders.all? { |appender| appender.instance_variable_get(:@log) != STDOUT }
          app.config.semantic_logger.add_appender(io: STDOUT, level: app.config.log_level, formatter: app.config.rails_semantic_logger.format)
        end
      elsif Rails.env.test?
        # Do nothing, leave appending to test.log file in place
      else
        # Use semantic_logger logging setup to log JSON to STDOUT
        app.config.rails_semantic_logger.add_file_appender = false
        app.config.rails_semantic_logger.format = :json
        app.config.semantic_logger.add_appender(io: STDOUT, level: app.config.log_level, formatter: app.config.rails_semantic_logger.format)
      end
    end

    initializer "fixings.configure_logging_middleware" do |app|
      app.config.log_tags ||= {}
      app.config.log_tags[:request_id] = :request_id
      app.config.log_tags[:client_session_id] = ->(request) { request.headers["X-Client-Session-Id"] }

      # Make sure that the semantic logger middleware which evaluats the above log_tags procs has a session on the request
      app.middleware.move_after ActionDispatch::Session::CacheStore, RailsSemanticLogger::Rack::Logger, app.config.log_tags
      app.middleware.insert_before ActionDispatch::Static, Fixings::SilentLogMiddleware, silence: ["/health_check", %r{^/assets/}, "/favicon.ico"]
    end

    initializer "fixings.configure_bullet" do
      if Rails.env.development?
        Bullet.enable = true
        Bullet.rails_logger = true
      end
    end

    initializer "fixings.docker_for_mac_web_console" do |app|
      if Rails.env.development?
        # Whitelist docker-for-mac ips for web console
        app.config.web_console.permissions = ["172.18.0.0/16", "172.19.0.0/16"]
      end
    end
  end
end
