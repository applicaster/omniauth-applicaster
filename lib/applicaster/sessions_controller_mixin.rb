module Applicaster
  module SessionsControllerMixin
    def new
      Rails.logger.info("New session initiated. Redirecting to /auth/applicaster. IP: #{request.remote_ip}, User Agent: #{request.user_agent}")
      redirect_to "/auth/applicaster"
    end

    def create
      session[:omniauth_credentials] = omniauth_credentials
      Rails.logger.info("Session created successfully for user. IP: #{request.remote_ip}, User Agent: #{request.user_agent}, Params: #{safe_user_params.inspect}")

      redirect_to(session.delete(:path_before_login) || '/')
    end

    def destroy
      user_email = current_user.email rescue "Unknown"
      Rails.logger.info("Session destroyed for user: #{user_email}. IP: #{request.remote_ip}, User Agent: #{request.user_agent}")

      reset_session
      redirect_to config.base_url
    end

    def failure
      Rails.logger.error({
        message: "[Login Failed] - Omniauth error with strategy '#{params[:strategy]}': #{params[:message]}",
        origin: params[:origin],
        IP: request.remote_ip,
        UserAgent: request.user_agent,
        Params: params[:origin],
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
