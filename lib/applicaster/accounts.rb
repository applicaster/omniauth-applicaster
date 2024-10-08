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
            conn.request :oauth2, options[:token], token_type: "param"
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
          conn.response :raise_error
          # conn.response :logger, Rails.logger
          # conn.response :logger, Logger.new(STDOUT)
          conn.adapter config.faraday_adapter
        end
      end

      def current_request
        config.request_proc.call if config.request_proc
      end

      def log_with_request_context(message)
        request = current_request
        log_message = "#{message}, IP: #{request&.remote_ip}, User Agent: #{request&.user_agent}"

        Rails.logger.error(log_message)
      end

      def user_from_token(token)
        Rails.logger.info("Fetching user with token: #{token}")
        user = Applicaster::Accounts::User.new(
          connection(token: token)
            .get("/api/v1/users/current.json")
            .body
        )
        if user.nil?
          Rails.logger.error("[Login Failed] - User fetch failed. Token: #{token}")
        end
        user
      rescue Faraday::ClientError => e
        if e.response && e.response[:status] == 401
          log_with_request_context("[Login Failed] - Unauthorized access attempt detected. Invalid token: #{token}, Error: #{e.message}")
          nil
        else
          log_with_request_context("[Login Failed] - Error fetching user. Token: #{token}, Error: #{e.message}")
          raise
        end
      end

      def user_by_id_and_token(id, token)
        Applicaster::Accounts::User.new(
          connection(token: token)
            .get("/api/v1/users/#{id}.json")
            .body
        )
      rescue Faraday::ResourceNotFound
        log_with_request_context("[Login Failed] - User not found. ID: #{id}, Token: #{token}")
        nil
      end

      def accounts_from_token(token)
        Rails.logger.info("Fetching accounts with token: #{token}")
        connection(token: token)
          .get("/api/v1/accounts.json")
          .body
          .map {|a| Account.new(a) }
      rescue Faraday::ClientError => e
        Rails.logger.error("Failed to fetch accounts. Token: #{token}, Error: #{e.message}")
        raise
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
    rescue Faraday::ClientError => e
      log_with_request_context("[Login Failed] - Failed to fetch user data from Omniauth. Error: #{e.message}")
      raise
    end

    def accounts
      self.class.accounts_from_token(client_credentials_token.token)
    end

    def find_user_by_id(id)
      Rails.logger.info("Finding user by ID: #{id}")
      self.class.user_by_id_and_token(id, client_credentials_token.token)
    rescue Faraday::ResourceNotFound
      Rails.logger.error("[Login Failed] - User not found by ID: #{id}")
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
    rescue OAuth2::Error => e
      log_with_request_context("[Login Failed] - Failed to get client credentials token. Error: #{e.message}")
      raise
    end
  end
end
