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

And then set up the followings things in the app:

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

## JavaScript / TypeScript config

We have those fixings too!

Create `.eslintrc.js` in your project with this content:

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
