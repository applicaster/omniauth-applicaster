module Applicaster
  class User
    attr_accessor :user_json

    def initialize(user_json)
      @user_json = user_json.symbolize_keys
    end

    def id
      user_json[:id]
    end

    def name
      user_json[:name]
    end

    def email
      user_json[:email]
    end

    def global_roles
      user_json[:global_roles]
    end

    def permissions
      user_json[:permissions]
    end

    def admin
      puts user_json.inspect
      user_json[:admin]
    end

    def admin?
      !!admin
    end
  end
end
