RSpec.describe Applicaster::Accounts::Configuration do
  let(:config) { described_class.new }

  specify "defaults" do
    expect(config.attributes).to eq({
      base_url: "https://accounts.applicaster.com/",
      client_id: nil,
      client_secret: nil,
      retries: 2,
      timeout: 1.0,
      faraday_adapter: :excon,
    })
  end

  describe "#base_url" do
    it "defaults to env var ACCOUNTS_BASE_URL" do
      base_url = "http://example.com"

      with_env_var("ACCOUNTS_BASE_URL", base_url) do
        expect(config.base_url).to eq(base_url)
      end
    end
  end

  describe "#client_id" do
    it "defaults to env var ACCOUNTS_CLIENT_ID" do
      with_env_var("ACCOUNTS_CLIENT_ID", "test-client-id") do
        expect(config.client_id).to eq("test-client-id")
      end
    end
  end

  describe "#client_secret" do
    it "defaults to env var ACCOUNTS_CLIENT_SECRET" do
      with_env_var("ACCOUNTS_CLIENT_SECRET", "test-client-secret") do
        expect(config.client_secret).to eq("test-client-secret")
      end
    end
  end
end
