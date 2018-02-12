module Applicaster
  module SessionsControllerMixin
    def new
      redirect_to "/auth/applicaster"
    end

    def create
      session[:omniauth_credentials] = omniauth_credentials

      redirect_to(session.delete(:path_before_login) || '/')
    end

    def destroy
      Applicaster::Accounts.new.delete_session_for_token(current_access_token)
      reset_session

      redirect_to "/"
    end

    def failure
      Rails.logger.warn({
        message: "Omniauth error with strategy '#{params[:strategy]}': #{params[:message]}",
        origin: params[:origin],
      })
      flash[:notice] = "There was a problem logging in"
      redirect_to "/"
    end

    protected

    def omniauth_credentials
      request.env['omniauth.auth'].credentials.to_hash.symbolize_keys
    end
  end
end
