class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.create!(user_params)
    EmailVerificationsMailer.verify(@user).deliver_later
    @user.update!(verification_sent_at: Time.current)
    session[:pending_verification_user_id] = @user.id
    redirect_to new_email_verification_url
  rescue ActiveRecord::RecordNotUnique
    redirect_to new_session_url(email_address: user_params[:email_address]), notice: "You already have an account. Please sign in."
  end

  private
    def user_params
      params.require(:user).permit(:name, :email_address, :password)
    end
end
