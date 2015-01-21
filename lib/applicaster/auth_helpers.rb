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
        session[:path_before_login] = url_for(params)
        redirect_to '/auth/applicaster'
      end
    end

    def current_access_token
      session[:omniauth_credentials][:token] if session[:omniauth_credentials]
    end

    protected

    def clear_omniauth_credentials
      session.delete(:omniauth_credentials)
    end

    def user_from_session
      return nil unless current_access_token

      Applicaster::Accounts.user_from_token(current_access_token).tap do |user|
        clear_omniauth_credentials unless user
      end
    end
  end
end

