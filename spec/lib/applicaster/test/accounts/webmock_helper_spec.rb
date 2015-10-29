require "spec_helper"

RSpec.describe Applicaster::Test::Accounts::WebMockHelper do
  let(:including_class) { Class.new { include(Applicaster::Test::Accounts::WebMockHelper) } }
  subject(:instace) { including_class.new }

  it { is_expected.to respond_to(:stub_accounts_user_show_response) }
  it { is_expected.to respond_to(:stub_accounts_index_response) }
  it { is_expected.to respond_to(:stub_client_credentials_request) }
  it { is_expected.to respond_to(:accounts_mock_data) }
  it { is_expected.to respond_to(:client_credentials_token) }
end
