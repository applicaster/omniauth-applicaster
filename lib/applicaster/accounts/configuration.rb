module Applicaster
  class Accounts
    class Configuration
      include Virtus.model

      # The base URL of the accounts service
      attribute :base_url, String,
        default: :default_base_url

      # OAuth2 provider client ID
      attribute :client_id, String,
        default: proc { ENV["ACCOUNTS_CLIENT_ID"] }

      # OAuth2 provider client secret
      attribute :client_secret, String,
        default: proc { ENV["ACCOUNTS_CLIENT_SECRET"] }

      # Number of times to retry safe requests
      attribute :retries, Integer,
        default: 2

      # Number of seconds before a request will be timed out
      attribute :timeout, Float,
        default: 1


      def default_base_url
        ENV["ACCOUNTS_BASE_URL"] || "https://accounts.applicaster.com/"
      end
    end
  end
end
