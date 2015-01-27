module Applicaster
  class Accounts
    class Permission
      include Virtus.model

      attribute :account_id, String
      attribute :roles, Array[String]
    end
  end
end
