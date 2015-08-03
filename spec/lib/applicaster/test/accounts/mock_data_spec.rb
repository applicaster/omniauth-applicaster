require "spec_helper"

RSpec.describe Applicaster::Test::Accounts::MockData do
  subject(:mock_data) { described_class.new }

  describe "#all_accounts_attributes" do
    it "has 2 elements" do
      expect(mock_data.all_accounts_attributes.size).to eq(2)
    end

    describe "returned account" do
      subject(:account) { mock_data.all_accounts_attributes.first }
      let(:id_regexp) { /^11223344\d{16}$/ }

      it { is_expected.to include(id: id_regexp) }
      it { is_expected.to include(old_id: id_regexp) }
      it { is_expected.to include(name: /Test Account \d+/) }
    end
  end
end
