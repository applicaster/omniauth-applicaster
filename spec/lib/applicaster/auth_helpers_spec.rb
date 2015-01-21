RSpec.describe Applicaster::AuthHelpers do
  let(:dummy_class) { Class.new(DummyController) { include Applicaster::AuthHelpers } }
  let(:controller) { dummy_class.new }

  before do
    allow(controller).to receive(:session).and_return(session)

    stub_current_user_requests
  end

  describe "#current_user" do
    context "when token in session is valid" do
      it "returns current_user" do
        expect(controller.current_user.id).to eq("123")
      end

      it "memoizes value" do
        expect(Applicaster::Accounts).to receive(:user_from_token)
          .once
          .and_call_original

        controller.current_user
        controller.current_user
      end
    end

    context "when token in session is invalid" do
      it "removes token from session" do
        controller.current_user

        expect(controller.session).to_not have_key(:omniauth_credentials)
      end

      def session
        super.tap do |session|
          session[:omniauth_credentials][:token] = "invalid-access-token"
        end
      end
    end
  end

  describe "#user_signed_in?" do
    context "when current_user is truthy" do
      before do
        allow(controller).to receive(:current_user).and_return({})
      end

      it "returns true" do
        expect(controller.user_signed_in?).to be true
      end
    end

    context "when current_user is nil" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it "returns false" do
        expect(controller.user_signed_in?).to be false
      end
    end
  end

  describe "#authenticate_user!" do
    context "when current_user is truthy" do
      before do
        allow(controller).to receive(:current_user).and_return({})
      end

      it "does not redirect" do
        expect(controller).to_not receive(:redirect_to)
        controller.authenticate_user!
      end
    end

    context "when current_user is nil" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:url_for).and_return("/current")
      end

      it "redirects to '/auth/applicaster'" do
        expect(controller).to receive(:redirect_to).with("/auth/applicaster")
        controller.authenticate_user!
      end

      it "saves the path of the current request" do
        controller.authenticate_user!

        expect(controller.session[:path_before_login]).to eq("/current")
      end
    end
  end

  describe "#current_access_token" do
    it "returns access token" do
      expect(controller.current_access_token).to eq(
        session[:omniauth_credentials][:token]
      )
    end

    context "when session has no omniauth_credentials" do
      it "returns nil" do
        expect(controller.current_access_token).to be nil
      end

      def session
        {}
      end
    end
  end

  def session
    {
      omniauth_credentials: {
        token: "valid-access-token"
      }
    }
  end
end
