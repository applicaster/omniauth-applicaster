module Applicaster
  module Test
    module Accounts
      class MockData
        def all_accounts_attributes
          @all_accounts_attributes ||= (1..2).map do |i|
            sequence = Test.inc_sequence
            id = Test.generate_object_id(sequence)
            {
              id: id,
              name: "Test Account #{sequence}",
              old_id: id,
            }
          end
        end

        def user_attributes
          id = Test.inc_sequence
          {
            id: id,
            name: "Test User #{id}",
            email: "test-user#{id}@example.com",
          }
        end
      end
    end
  end
end
