begin
  require "webmock/rspec"
rescue NameError
  warn "webmock is not installed."
  warn "Applicaster::Test::Accounts::WebMockHelper uses webmock to setup stubs."
end

module Applicaster
  module Test
    module Accounts
      module WebMockHelper
        def stub_accounts_user_show_response(options = {})
          user = options[:user] || accounts_mock_data.user_attributes

          stub_request(:get, accounts_base_url.join("/api/v1/users/#{user[:id]}.json"))
            .with(query: { access_token: options[:token] })
            .to_return(successful_json_response(user))
        end

        def stub_accounts_index_response(options = {})
          accounts = options[:accounts] || accounts_mock_data.all_accounts_attributes

          stub_request(:get, accounts_base_url.join("/api/v1/accounts.json"))
            .with(query: { access_token: options[:token] })
            .to_return(successful_json_response(accounts))
        end

        def stub_client_credentials_request
          url = accounts_base_url.join("/oauth/token")
          url.user = Applicaster::Accounts.config.client_id
          url.password = Applicaster::Accounts.config.client_secret

          stub_request(:post, url)
            .with(body: { "grant_type" => "client_credentials" })
            .to_return(successful_json_response(access_token: client_credentials_token))
        end

        def accounts_mock_data
          @accounts_mock_data ||= Test::Accounts::MockData.new
        end

        def client_credentials_token
          "client-credentials-token"
        end

        private

        def successful_json_response(body)
          {
            status: 200,
            body: body.to_json,
            headers: { "Content-Type" => "application/json" },
          }
        end

        def accounts_base_url
          Addressable::URI.parse(Applicaster::Accounts.config.base_url)
        end
      end
    end
  end
end
