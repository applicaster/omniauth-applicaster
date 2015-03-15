# Omniauth::Applicaster

An omniauth strategy for Applicaster's OAuth2 provider and an SDK for the
Accounts service.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-applicaster'
```

## Usage

### Omniauth strategy in Rails

See [Omniauth](https://github.com/intridea/omniauth) for setting up omniauth.

```ruby
# config/initializers/applicaster.rb

Applicaster::Accounts.configure do |config|
  config.client_id = "my-service-uid"
  config.client_secret = "my-service-secret"

  if Rails.env.development?
    # Use local accounts service with Pow when in development
    config.base_url = "http://accounts2.dev/"

    # Set the timeout for the accounts SDK requests in seconds
    config.timeout = 60
  end
end
```

```ruby
# config/initializers/omniauth.rb

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :applicaster
end
```

In addition, the gem provides `Applicaster::AuthHelpers` and
`Applicaster::SessionsControllerMixin` for easy integration with Rails
projects.

```ruby
class ApplicationController < ActionController::Base
  include Applicaster::AuthHelpers
end
```

```ruby
class SessionsController < ApplicationController
  include Applicaster::SessionsControllerMixin
end
```

In your `routes.rb` you need to add:

```ruby
MyApp::Application.routes.draw do
  get     "/login",  to: "sessions#new",     as: :login
  delete  "/logout", to: "sessions#destroy", as: :logout

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure",            to: "sessions#failure"
end
```

### Configuration

For the possible configuration options please see
[Applicaster::Accounts::Configuration](lib/applicaster/accounts/configuration.rb)

If not provided via the configuration block, the OAuth client ID and client
secret are read from the environment variables `ACCOUNTS_CLIENT_ID` and
`ACCOUNTS_CLIENT_SECRET` respectivly.

The gem uses `https://accounts2.applicaster.com` as the site's endpoint by
default to change this use the `base_url` config option or set the
`ACCOUNTS_BASE_URL` environment variable. This is useful for example when
running a local version of the accounts service


### Accounts SDK

#### List all available accounts

```ruby
service = Applicaster::Accounts.new

service.accounts.each do |account|
  # account is an Applicaster::Accounts::Account instance
end
```

#### Get a user using an access token

```ruby
user = Applicaster::Accounts.user_from_token(access_token)
# user is an Applicaster::Accounts::User instance
```

#### Get a list of accounts for a specific user

```ruby
accounts = Applicaster::Accounts.accounts_from_token(access_token)
# accounts is an array of `Applicaster::Accounts::User` objects
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/omniauth-applicaster/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
