require "omniauth-oauth2"
require "applicaster/accounts"

module OmniAuth
  module Strategies
    class Applicaster < OmniAuth::Strategies::OAuth2
      option :name, :applicaster

      uid { raw_info["id"] }

      info do
        {
          name: raw_info["name"],
          email: raw_info["email"],
          admin: raw_info["admin"],
          account_id: raw_info["account_id"],
          global_roles: raw_info["global_roles"],
          permissions: raw_info["permissions"],
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/users/current.json').parsed
      end

      def client
        ::Applicaster::Accounts.oauth_client
      end
    end
  end
end
