require "faraday"
require "faraday_middleware"
require "virtus"

module Applicaster
  class Accounts
    autoload :Account, "applicaster/accounts/account"
    autoload :Configuration, "applicaster/accounts/configuration"
    autoload :Permission, "applicaster/accounts/permission"
    autoload :User, "applicaster/accounts/user"

    RETRYABLE_STATUS_CODES = [500, 502, 503, 504]

    class << self
      def connection(options = {})
        conn_opts = {
          url: config.base_url,
          request: { timeout: config.timeout }
        }

        Faraday.new(conn_opts) do |conn|
          if options[:token]
            conn.request :oauth2, options[:token], token_type: 'param'
          end

          conn.request :json
          conn.request :retry,
            max: config.retries,
            interval: 0.05,
            backoff_factor: 2,
            exceptions: [Faraday::ClientError, Faraday::TimeoutError, Faraday::ConnectionFailed],
            methods: [],
            retry_if: ->(env, exception) {
              env[:method] == :get &&
                (exception.is_a?(Faraday::TimeoutError) ||
                 RETRYABLE_STATUS_CODES.include?(env[:status]))
            }


          conn.response :json, content_type: /\bjson$/
          # conn.response :logger, Rails.logger
          # conn.response :logger, Logger.new(STDOUT)
          conn.response :raise_error

          conn.adapter config.faraday_adapter
        end
      end

      def user_from_token(token)
        Applicaster::Accounts::User.new(
          connection(token: token)
            .get("/api/v1/users/current.json")
            .body
        )
      rescue Faraday::ClientError => e
        if e.response && e.response[:status] == 401
          nil
        else
          raise
        end
      end

      def user_by_id_and_token(id, token)
        Applicaster::Accounts::User.new(
          connection(token: token)
            .get("/api/v1/users/#{id}.json")
            .body
        )
      end

      def accounts_from_token(token)
        connection(token: token)
          .get("/api/v1/accounts.json")
          .body
          .map {|a| Account.new(a) }
      end

      def config
        @config ||= Configuration.new
      end

      def configure
        yield config
      end

      def oauth_client(config = config())
        ::OAuth2::Client.new(
          config.client_id,
          config.client_secret,
          site: config.base_url,
          authorize_url: "/oauth/authorize",
          auth_scheme: :basic_auth,
        )
      end
    end

    def user_data_from_omniauth(omniauth_credentials)
      access_token(omniauth_credentials).get("/api/v1/users/current.json").parsed
    end

    def accounts
      self.class.accounts_from_token(client_credentials_token.token)
    end

    def find_user_by_id(id)
      self.class.user_by_id_and_token(id, client_credentials_token.token)
    rescue Faraday::ResourceNotFound
      nil
    end

    def connection(*args)
      self.class.connection(*args)
    end

    protected

    def client_credentials_token
      @client_credentials_token ||= self.class.oauth_client
        .client_credentials
        .get_token
    end
  end
end
