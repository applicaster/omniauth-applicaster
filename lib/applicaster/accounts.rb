require "faraday"
require "faraday_middleware"
require "virtus"

module Applicaster
  class Accounts
    autoload :Account, "applicaster/accounts/account"
    autoload :User, "applicaster/accounts/user"

    RETRYABLE_STATUS_CODES = [500, 503, 502]
    FARADAY_TIMEOUT = 0.5

    attr_accessor :client_id
    attr_accessor :client_secret

    class << self
      def default_site
        "https://accounts2.applicaster.com"
      end

      def site
        URI.parse(ENV["ACCOUNTS_BASE_URL"] || default_site)
      end

      def connection(options = {})
        Faraday.new(url: site, request: { timeout: FARADAY_TIMEOUT } ) do |conn|
          if options[:token]
            conn.request :oauth2, options[:token]
          end

          conn.request :json
          conn.request :retry,
            interval: 0.05,
            backoff_factor: 2,
            exceptions: [Faraday::ClientError, Faraday::TimeoutError],
            methods: [],
            retry_if: -> (env, exception) {
              env[:method] == :get &&
              RETRYABLE_STATUS_CODES.include?(env[:status])
            }


          conn.response :json, content_type: /\bjson$/
          # conn.response :logger, Rails.logger
          # conn.response :logger, Logger.new(STDOUT)
          conn.response :raise_error

          conn.adapter Faraday.default_adapter
        end
      end

      def user_from_token(token)
        Applicaster::Accounts::User.new(
          connection(token: token)
            .get("/api/v1/users/current.json")
            .body
        )
      rescue Faraday::ClientError => e
        if e.response[:status] == 401
          nil
        else
          raise e
        end
      end
    end

    def initialize(client_id = nil, client_secret = nil)
      @client_id = client_id || ENV["ACCOUNTS_CLIENT_ID"]
      @client_secret = client_secret || ENV["ACCOUNTS_CLIENT_SECRET"]
    end

    def user_data_from_omniauth(omniauth_credentials)
      access_token(omniauth_credentials).get("/api/v1/users/current.json").parsed
    end

    def accounts
      connection(token: client_credentials_token.token)
        .get("/api/v1/accounts.json")
        .body
        .map {|a| Account.new(a) }
    end

    def connection(*args)
      self.class.connection(*args)
    end

    protected

    def client_credentials_token
      @client_credentials_token ||= client.client_credentials.get_token
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
