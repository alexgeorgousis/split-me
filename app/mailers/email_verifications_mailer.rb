class EmailVerificationsMailer < ApplicationMailer
  def verify(user)
    @user = user
    mail subject: "Verify your email address", to: user.email_address
  end
end
