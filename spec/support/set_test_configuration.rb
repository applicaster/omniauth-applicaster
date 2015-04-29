RSpec.configure do |config|
  config.before do
    Applicaster::Accounts.instance_variable_set(:@config, nil)
    Applicaster::Accounts.configure do |accounts_config|
      accounts_config.client_id = "client-id"
      accounts_config.client_secret = "client-secret"
    end
  end
end
