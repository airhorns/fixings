# frozen_string_literal: true
# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development?
  require "annotate"
  task :set_annotation_options do # rubocop:disable Rails/RakeEnvironment
    # You can override any of these by setting an environment variable of the
    # same name.
    Annotate.set_defaults(
      "additional_file_patterns" => [],
      "routes" => "false",
      "models" => "true",
      "position_in_routes" => "before",
      "position_in_class" => "before",
      "position_in_test" => "before",
      "position_in_fixture" => "before",
      "position_in_factory" => "before",
      "position_in_serializer" => "before",
      "show_foreign_keys" => "true",
      "show_complete_foreign_keys" => "false",
      "show_indexes" => "true",
      "simple_indexes" => "false",
      "model_dir" => "app/models",
      "root_dir" => "",
      "include_version" => "false",
      "require" => "",
      "exclude_tests" => "false",
      "exclude_fixtures" => "false",
      "exclude_factories" => "false",
      "exclude_serializers" => "false",
      "exclude_scaffolds" => "true",
      "exclude_controllers" => "true",
      "exclude_helpers" => "true",
      "exclude_sti_subclasses" => "false",
      "ignore_model_sub_dir" => "false",
      "ignore_columns" => nil,
      "ignore_routes" => nil,
      "ignore_unknown_models" => "false",
      "hide_limit_column_types" => "integer,bigint,boolean",
      "hide_default_column_types" => "json,jsonb,hstore",
      "skip_on_db_migrate" => "false",
      "format_bare" => "true",
      "format_rdoc" => "false",
      "format_markdown" => "false",
      "sort" => "false",
      "force" => "false",
      "frozen" => "false",
      "classified_sort" => "true",
      "trace" => "false",
      "wrapper_open" => nil,
      "wrapper_close" => nil,
      "with_comment" => "true",
    )
  end

  Annotate.load_tasks
end

namespace :db do
  desc "Truncate all existing data. Provided by the fixings gem"
  task :truncate => "db:load_config" do
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.connection.tables.each do |table|
      next if table == "schema_migrations"
      ActiveRecord::Base.connection.execute("TRUNCATE #{table} CASCADE")
    end
  end
end

# frozen_string_literal: true
require "English"
require "optparse"

namespace :job do
  desc "Run a Que job inline. Used by other infrastructure components. Provided by the fixings gem"
  task :run_inline => :environment do
    options = { args: [] }

    optparse = OptionParser.new do |opts|
      opts.on("-j", "--job-class ARG", "what job class to execute") do |klass|
        options[:job_class] = klass.constantize
      end

      opts.on("-a", "--args ARG", "JSON serialized array of arguments to pass to class") do |args|
        options[:args] = JSON.parse(args)
      end

      opts.on("-h", "--help", "Display this screen") do
        puts opts
        exit
      end
    end

    begin
      args = optparse.order!(ARGV) { }
      optparse.parse!(args)

      mandatory = [:job_class]
      missing = mandatory.select { |param| options[param].nil? }
      if !missing.empty?
        puts "Missing options: #{missing.join(", ")}"
        puts optparse
        exit
      end
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument
      puts $ERROR_INFO.to_s
      puts optparse
      exit
    end

    Rails.logger.info "Running job inline", job_class: options[:job_class], args: options[:args]
    options[:job_class].run(*options[:args])
    true
  end
end
