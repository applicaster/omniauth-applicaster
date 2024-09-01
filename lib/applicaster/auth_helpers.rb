module Applicaster
  module AuthHelpers
    def current_user
      @current_user ||= user_from_session
    end

    def user_signed_in?
      !current_user.nil?
    end

    def authenticate_user!
      unless current_user
        log_unauthorized_access
        store_location!
        redirect_to '/auth/applicaster'
      end
    end

    def current_access_token
      if credentials = session[:omniauth_credentials]
        credentials[:token] || credentials["token"]
      end
    end

    protected

    def store_location!
      session[:path_before_login] = if request.get?
        request.fullpath
      else
        request.referrer
      end
    end

    def clear_omniauth_credentials
      session.delete(:omniauth_credentials)
    end

    def user_from_session
      return nil unless current_access_token

      Applicaster::Accounts.user_from_token(current_access_token).tap do |user|
        clear_omniauth_credentials unless user
      end
    rescue Faraday::ClientError => e
      log_failed_user_fetch(e)
      nil
    end

    def log_unauthorized_access
      user_email = current_user&.email || "Unknown User"
      user_ip = request.remote_ip
      user_agent = request.user_agent
      requested_path = request.fullpath

      Rails.logger.error(
        "[Unauthorized Access Attempt] - User: #{user_email}, IP: #{user_ip}, User Agent: #{user_agent}, Requested Path: #{requested_path}. Redirecting to '/auth/applicaster'."
      )
    end

    def log_failed_user_fetch(exception)
      user_email = current_user&.email || session[:omniauth_credentials]&.fetch(:email, "Unknown User")
      user_ip = request.remote_ip
      user_agent = request.user_agent
      requested_path = request.fullpath

      Rails.logger.error(
        "[User Fetch Failed] - User: #{user_email}, IP: #{user_ip}, User Agent: #{user_agent}, Requested Path: #{requested_path}. Error: #{exception.message}",
      )
    end
  end
end

