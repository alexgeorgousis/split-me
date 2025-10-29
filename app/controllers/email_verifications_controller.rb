class EmailVerificationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new show create ]
  before_action :set_user_by_token, only: :show
  before_action :set_user_from_session, only: %i[ new create ]

  def new
  end

  def show
    @user.verify_email!
    start_new_session_for @user
    redirect_to root_path, notice: "Email verified successfully. Welcome!"
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_session_path, alert: "Verification link is invalid or has expired."
  end

  def create
    EmailVerificationsMailer.verify(@user).deliver_later
    @user.update!(verification_sent_at: Time.current)
    redirect_to new_email_verification_path, notice: "Verification email sent. Please check your inbox."
  end

  private
    def set_user_by_token
      @user = User.find_by_email_verification_token(params[:token])
      raise ActiveSupport::MessageVerifier::InvalidSignature unless @user
    end

    def set_user_from_session
      @user = User.find_by(id: session[:pending_verification_user_id])
      redirect_to new_session_path, alert: "Session expired. Please log in." unless @user
    end
end
