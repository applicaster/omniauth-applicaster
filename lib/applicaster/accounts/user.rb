module Applicaster
  class Accounts
    class User
      include Virtus.model

      attribute :id, String
      attribute :name, String
      attribute :email, String
      attribute :global_roles, Array[String]
      attribute :permissions, Array[Permission]
      attribute :admin, Boolean

      def admin?
        !!admin
      end

      def permission_for_account_id(account_id)
        permissions.find { |p| p.account_id == account_id }
      end
    end
  end
end
