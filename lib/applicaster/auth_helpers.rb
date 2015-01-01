require_relative "user"

module Applicaster
  module AuthHelpers
    def current_user
      return nil unless session[:omniauth_credentials]

      @current_user ||= user_from_session.tap do |user|
        session.delete(:omniauth_credentials) unless user
      end
    rescue OAuth2::Error => e
      session.delete(:omniauth_credentials)
      nil
    end

    def user_signed_in?
      !current_user.nil?
    end

    protected

    def authenticate_user!
      unless current_user
        session[:path_before_login] = url_for(params)
        redirect_to '/auth/applicaster'
      end
    end

    def user_from_session
      Applicaster::User.new(
        accounts_client.user_data_from_omniauth(session[:omniauth_credentials])
      )
    end

    def accounts_client
      Applicaster::Accounts.new(
        Settings.accounts_service.id,
        Settings.accounts_service.secret,
      )
    end
  end
end

