class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      verify user
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to root_url, status: :see_other
  end

  private
    def verify(user)
      if user.verified?
        start_new_session_for user
        redirect_to after_authentication_url
      else
        reject_unverified user
      end
    end

    def reject_unverified(user)
        session[:pending_verification_user_id] = user.id
        flash[:alert] = "Please verify your email address before logging in."
        flash[:show_resend_link] = true
        redirect_to new_session_path
    end
end
