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
  config.request_proc = -> { Thread.current[:request] }

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

  before_action :set_request_in_thread

  def set_request_in_thread
    Thread.current[:request] = request
  end
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

#### Get user by id

```ruby
service = Applicaster::Accounts.new
user = service.find_user_by_id(user_id)
# user is an Applicaster::Accounts::User instance
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


### Testing your app

The library contains helpers to make functional tests easier

In `spec/spec_helper.rb` add:
```ruby
RSpec.configure do |config|
  config.include Applicaster::Test::Accounts::WebMockHelper
end
```

You can use `accounts_mock_data` to access the fake data, for example:
`accounts_mock_data.all_accounts_attributes.first`
`accounts_mock_data.user_attributes`

in example groups that use the client_credentials flow use:
```ruby
before do
  stub_client_credentials_request
  stub_accounts_index_response(token: client_credentials_token)
end
```

in tests that use `find_user_by_id` method you can do the following:
```ruby

let(:user) { accounts_mock_data.user_attributes }
let(:accounts_service) { Applicaster::Accounts.new }

before do
  stub_client_credentials_request
  stub_accounts_user_show_response(user: user, token: client_credentials_token)
end

it "..." do
  expect(accounts_service.find_user_by_id(user[:id])).to ...
end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/omniauth-applicaster/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
