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

    protected

    def user_from_session
      return nil unless session[:omniauth_credentials]

      token = session[:omniauth_credentials][:token]
      Applicaster::Accounts.user_from_token(token).tap do |user|
        session.delete(:omniauth_credentials) unless user
      end
    end
  end
end

