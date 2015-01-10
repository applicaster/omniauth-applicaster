module Applicaster
  class Accounts
    class Account
      include Virtus.model

      attribute :id, String
      attribute :name, String
      attribute :timezone, String
      attribute :applicaster2_id, String
      attribute :old_id, String
    end
  end
end
