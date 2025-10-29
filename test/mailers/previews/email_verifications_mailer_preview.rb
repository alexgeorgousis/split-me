class EmailVerificationsMailerPreview < ActionMailer::Preview
  def verify
    EmailVerificationsMailer.verify(User.take)
  end
end
