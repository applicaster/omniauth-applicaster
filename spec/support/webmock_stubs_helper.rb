module WebmockStubsHelper
  RSpec.configure do |config|
    config.include self
  end

  def disable_webmock
    WebMock.allow_net_connect!
    yield
    WebMock.disable_net_connect!
  end

  def stub_client_credentials_request
    stub_request(:post, "https://client-id:client-secret@#{accounts_host}/oauth/token")
      .with(:body => {"grant_type"=>"client_credentials"})
      .to_return(successful_json_response(access_token: "client-credentials-token"))
  end

  def stub_current_user_requests
    stub_request(:get, "https://#{accounts_host}/api/v1/users/current.json")
      .with(query: { access_token: "valid-access-token" })
      .to_return(successful_json_response(mock_user_response))

    stub_request(:get, "https://#{accounts_host}/api/v1/users/current.json")
      .with(query: { access_token: "invalid-access-token" })
      .to_return(status: 401, body: "")
  end

  def stub_user_show_request_with_invalid_token(user_id, token)
    stub_request(:get, "https://#{accounts_host}/api/v1/users/#{user_id}.json")
      .with(query: { access_token: token })
      .to_return(status: 401, body: "")
  end

  def stub_user_show_request(user_id, token)
    stub_request(:get, "https://#{accounts_host}/api/v1/users/#{user_id}.json").
       with(query: { access_token: token }).
       to_return(successful_json_response(mock_user_response))
  end

  def accounts_host
    "accounts.applicaster.com"
  end

  def mock_user_response
    {
      id: "123"
    }
  end

  def successful_json_response(body)
    {
      status: 200,
      body: body.to_json,
      headers: {
        "Content-Type" => "application/json"
      }
    }
  end
end
