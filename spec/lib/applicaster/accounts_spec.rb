RSpec.describe Applicaster::Accounts do
  let(:accounts_service) { Applicaster::Accounts.new }

  describe "::RETRYABLE_STATUS_CODES" do
    it "is [500, 503, 502]" do
      expect(Applicaster::Accounts::RETRYABLE_STATUS_CODES).to eq([500, 503, 502])
    end
  end

  describe ".site" do
    it "returns a URI object" do
      expect(return_value).to be_kind_of(URI)
    end

    it "returns https://accounts2.applicaster.com" do
      expect(return_value.to_s).to eq("https://accounts2.applicaster.com")
    end

    context "when ACCOUNTS_BASE_URL is set" do
      around do |example|
        with_base_url("http://example.com") do
          example.run
        end
      end

      it "returns http://example.com" do
        expect(return_value.to_s).to eq("http://example.com")
      end
    end

    def return_value
      Applicaster::Accounts.site
    end
  end

  describe "#initialize" do
    it "accepts client_id and client_secret" do
      service = Applicaster::Accounts.new("my_client_id", "my_client_secret")

      expect(service.client_id).to eq("my_client_id")
      expect(service.client_secret).to eq("my_client_secret")
    end

    it "takes default values from ENV vars" do
      expect(accounts_service.client_id).to eq("client_id")
      expect(accounts_service.client_secret).to eq("client_secret")
    end
  end

  describe "#accounts" do
    before do
      stub_client_credentials_request
      stub_accounts_index_request
    end

    it "returns an array of Account objects" do
      expect(return_value).to be_kind_of(Array)
      expect(return_value.size).to eq(2)
      expect(return_value.first).to be_kind_of(Applicaster::Accounts::Account)
    end

    def return_value
      @return_value ||= accounts_service.accounts
    end

    def stub_accounts_index_request
      stub_request(:get, "https://accounts2.applicaster.com/api/v1/accounts.json").
         with(query: { access_token: "client-credentials-token" }).
         to_return(successful_json_response(mock_accounts_response))
    end

    def mock_accounts_response
      [
        {
          id: "1-account-1",
          name: "Account 1",
        },
        {
          id: "2-account-2",
          name: "Account 2",
        },
      ]
    end
  end

  describe ".connection" do
    let(:remote_url) { "https://accounts2.applicaster.com/test.json" }
    let(:request_stub) { stub_request(:get, remote_url) }

    context "with successful response" do
      before do
        request_stub
          .to_return(successful_json_response({key: "val"}))
      end

      it "encodes JSON" do
        expect(connection.get("/test.json").body).to eq("key" => "val")
      end
    end

    context "when server responds with 503" do
      before do
        request_stub
          .to_return(status: 503, body: "")
          .to_return(successful_json_response({}))
      end

      it "retries the request" do
        connection.get("/test.json")

        expect(request_stub).to have_been_requested.twice
      end
    end

    context "when server is not responding" do
      around do |example|
        with_base_url("http://localhost:6969") do
          WebMock.allow_net_connect!
          example.run
          WebMock.disable_net_connect!
        end
      end

      before do
        @server = TCPServer.new(6969)
      end

      it "times out after 0.5 second with 2 retries" do
        expect {
          connection.get("/test.json") rescue nil
        }.to change { Time.now }.by(a_value < 1.5)
      end
    end

    def connection
      Applicaster::Accounts.connection
    end
  end

  def with_base_url(url)
    value_bofre, ENV["ACCOUNTS_BASE_URL"] = ENV["ACCOUNTS_BASE_URL"], url
    yield
    ENV["ACCOUNTS_BASE_URL"] = value_bofre
  end
end
