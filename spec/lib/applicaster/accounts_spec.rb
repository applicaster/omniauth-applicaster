RSpec.describe Applicaster::Accounts do
  let(:accounts_service) { Applicaster::Accounts.new }

  describe "::RETRYABLE_STATUS_CODES" do
    it "is [500, 503, 502]" do
      expect(Applicaster::Accounts::RETRYABLE_STATUS_CODES).to eq([500, 503, 502])
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
      let(:timeout) { 0.1 }
      let(:retries) { 1 }
      let(:max_exec_time) { 1 + timeout + (timeout + 0.05) * retries }

      before do
        @server = TCPServer.new(6969)

        Applicaster::Accounts.configure do |config|
          config.base_url = "http://localhost:6969"
          config.timeout = timeout
          config.retries = retries
        end
      end

      it "times out after 0.1 second with 1 retry" do
        disable_webmock do
          expect {
            begin
              connection.get("/test.json")
            rescue Faraday::TimeoutError
            end
          }.to change { Time.now }.by(a_value < max_exec_time)
        end
      end
    end

    def connection
      Applicaster::Accounts.connection
    end
  end

  describe ".user_from_token" do
    let(:return_value) { Applicaster::Accounts.user_from_token(token) }

    before do
      stub_current_user_requests
    end

    context "when token is valid" do
      let(:token) { "valid-access-token" }

      it "returns an Applicaster::Accounts::User instance" do
        expect(return_value).to be_kind_of(Applicaster::Accounts::User)
      end
    end

    context "when token is invalid" do
      let(:token) { "invalid-access-token" }

      it "returns nil" do
        expect(return_value).to be nil
      end
    end
  end

  describe ".accounts_from_token" do
    let(:token) { "valid-access-token" }
    let(:return_value)  { Applicaster::Accounts.accounts_from_token(token) }

    before do
      stub_accounts_index_request(token)
    end

    it "returns an array of Applicaster::Accounts::Account" do
      expect(return_value).to be_kind_of(Array)
      expect(return_value.first).to be_kind_of(Applicaster::Accounts::Account)
    end
  end

  describe ".config" do
    it "returns an Applicaster::Accounts::Configuration" do
      expect(config).to be_kind_of(Applicaster::Accounts::Configuration)
    end

    def config
      Applicaster::Accounts.config
    end
  end

  describe ".configure" do
    it "yields with Applicaster::Accounts.config" do
      expect { |b| configure(&b) }.to yield_with_args(config)
    end

    def configure(&block)
      Applicaster::Accounts.configure(&block)
    end

    def config
      Applicaster::Accounts.config
    end
  end

  describe "#accounts" do
    before do
      stub_client_credentials_request
      stub_accounts_index_request("client-credentials-token")
    end

    it "returns an array of Account objects" do
      expect(return_value).to be_kind_of(Array)
      expect(return_value.size).to eq(2)
      expect(return_value.first).to be_kind_of(Applicaster::Accounts::Account)
    end

    def return_value
      @return_value ||= accounts_service.accounts
    end
  end

  def stub_accounts_index_request(token)
    stub_request(:get, "https://accounts2.applicaster.com/api/v1/accounts.json").
       with(query: { access_token: token }).
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
