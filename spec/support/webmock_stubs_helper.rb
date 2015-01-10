module WebmockStubsHelper
  RSpec.configure do |config|
    config.include self
  end

  def stub_client_credentials_request
    stub_request(:post, "https://client_id:client_secret@accounts2.applicaster.com/oauth/token").
       with(:body => {"grant_type"=>"client_credentials"}).
       to_return(successful_json_response(access_token: "client-credentials-token"))
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
