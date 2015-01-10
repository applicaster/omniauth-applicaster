module Applicaster
  class Accounts
    class User
      include Virtus.model

      attribute :id, String
      attribute :name, String
      attribute :email, String
      attribute :global_roles, Array[String]
      attribute :permissions, Array
      attribute :admin, Boolean

      def admin?
        !!admin
      end
    end
  end
end
