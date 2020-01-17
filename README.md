# Fixings

A Rails setup that makes you not have to think and works nice and good.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fixings'
```

Add this line to your test helper:

```ruby
require 'fixings/test_help
```

Copy this file to `.rubocop.yml`

```yml
inherit_gem:
  fixings:
    - .rubocop.yml
```

Fixings also couples tightly to the middleware structure to set request logging up properly. This requires `ActionDispatch::Session::CacheStore` and `ActionDispatch::Static` to be in the middleware stack. For a fresh Rails app, this isn't the case because of the session store. As of now, Fixings requires you use the `CacheStore` for your sessions, which is generally better than cookies for a production app anyways.

To use cache store, replace the contents of `config/initializers/session_store.rb` with

```ruby
# frozen_string_literal: true
# Be sure to restart your server when you modify this file.
Rails.application.config.session_store(:cache_store, key: "spellcheck_#{Rails.env.to_s}_sessions")
```

#### Sentry (via sentry-raven)

Sentry is auto included and lightly configured. Set it up for the specific application with something like this in `config/initializers/sentry.rb`:

```ruby
Raven.configure do |config|
  if Rails.env.production?
    config.dsn = ENV["BACKEND_SENTRY_DSN"]
  end
end
```

#### Log Tags (via rails-semantic-logger)

Fixings sets up `rails-semantic-logger` and configures it to log to STDOUT in all environments, in plain text for development and in JSON for production.

To add more details from the request context, add keys to the `config.log_tags` hash in your `config/application.rb`:

```ruby
class Application < Rails::Application
    # ...
    config.log_tags[:user_id] = ->(request) { request.session[:current_user_id] }
    config.log_tags[:account_id] = ->(request) { request.session[:current_account_id] }
end
```

#### Flipper

Fixings sets up Flipper for beta flag flipping.

#### VCR for testing

Fixings sets up VCR for testing and configures it to run for every test case automatically. It also automatically filters the `Authorization` headers from saved cassettes. You probably have parameters you want to filter out:


```ruby
ENV["SHOPIFY_OAUTH_ACCESS_TOKEN"] ||= "test_access_token"

VCR.configure do |config|
  config.filter_sensitive_data("<SHOPIFY_OAUTH_ACCESS_TOKEN>") { ENV["SHOPIFY_OAUTH_ACCESS_TOKEN"] }

  config.fixings_query_matcher_param_exclusions << "appsecret_proof"
end

```


#### Routes and Engine Mounts

Mount the various engines que brings along with it:

```ruby
Rails.application.routes.draw do
  # ...

  health_check_routes  # added by the health check gem included by fixings
  mount Flipper::UI.app(Flipper) => "/flipper"  # useful for administering beta flags powered by flipper
end
```

A more complicated setup might look like this with a host constraint:

```ruby
Rails.application.routes.draw do
  health_check_routes

  constraints host: Rails.configuration.x.domains.admin do
    constraints AdminAuthConstraint.new do
      mount Que::Web, at: "/que"
      mount Flipper::UI.app(Flipper) => "/flipper"
    end

    mount Trestle::Engine => Trestle.config.path
  end

  # ...
end
```

## Rubocop Config

Getcher lint-y fixin's for Ruby code by putting this in `.rubocop.yml`:

```yaml
AllCops:
  Exclude:
    - "bin/**/*"
    - "vendor/**/*"
    - "node_modules/**/*"
    - "test/scratch/**/*"
  TargetRubyVersion: 2.7

inherit_gem:
  fixings:
    - .rubocop.yml
```

## JavaScript / TypeScript config

We have those fixings too!

Add the required packages:

```
yarn add --dev @fixings/prettier-config @fixings/eslint-config
```

Create `.eslintrc.json` in your project with this content:

```json
{
    "extends": "@fixings/eslint-config"
}
```

Create `.prettierrc.json` in your project with this content:

```json
"@fixings/prettier-config"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hornairs/fixings. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hornairs/fixings/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Fixings project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hornairs/fixings/blob/master/CODE_OF_CONDUCT.md).
