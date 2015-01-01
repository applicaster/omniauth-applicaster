module Applicaster
  module SessionsControllerMixin
    def new
      redirect_to "/auth/applicaster"
    end

    def create
      session[:omniauth_credentials] = auth_hash.credentials.to_hash

      redirect_to(session.delete(:path_before_login) || '/')
    end

    def destroy
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

    def auth_hash
      request.env['omniauth.auth']
    end

    def access_token
      @access_token ||= OAuth2::AccessToken.new(
        client,
        auth_hash.credentials.token,
        auth_hash.credentials.to_hash.except("token", "expires"),
      )
    end

  end
end
