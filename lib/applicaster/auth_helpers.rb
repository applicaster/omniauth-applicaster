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
    end
  end
end

