module Applicaster
  module Test
    module Accounts
      autoload :MockData, "applicaster/test/accounts/mock_data"
      autoload :WebMockHelper, "applicaster/test/accounts/web_mock_helper"
    end

    module_function
    def inc_sequence
      @sequence ||= 0
      @sequence += 1
    end

    def generate_object_id(sequence = inc_sequence)
      sprintf("11223344%016d", sequence)
    end
  end
end
