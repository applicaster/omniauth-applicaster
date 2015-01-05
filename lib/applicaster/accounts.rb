module Applicaster
  class Accounts
    attr_accessor :client_id
    attr_accessor :client_secret

    class << self
      def default_site
        "https://accounts2.applicaster.com"
      end

      def site
        URI.parse(ENV["ACCOUNTS_BASE_URL"] || default_site)
      end
    end

    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret
    end

    def user_data_from_omniauth(omniauth_credentials)
      access_token(omniauth_credentials).get("/api/v1/users/current.json").parsed
    end

    def client
      @client ||= ::OAuth2::Client.new(
        client_id,
        client_secret,
        site: Applicaster::Accounts.site,
        authorize_url: "/oauth/authorize",
      )
    end

    def access_token(omniauth_credentials)
      @access_token ||= OAuth2::AccessToken.new(
        client,
        omniauth_credentials["token"],
        omniauth_credentials.except("token", "expires"),
      )
    end
  end
end
