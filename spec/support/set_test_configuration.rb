RSpec.configure do |config|
  config.before do
    Applicaster::Accounts.instance_variable_set(:@config, nil)
    Applicaster::Accounts.configure do |config|
      config.client_id = "client-id"
      config.client_secret = "client-secret"
    end
  end
end
