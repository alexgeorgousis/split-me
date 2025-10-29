module User::EmailVerification
  extend ActiveSupport::Concern

  included do
    generates_token_for :email_verification, expires_in: 24.hours
  end

  class_methods do
    def find_by_email_verification_token(token)
      find_by_token_for(:email_verification, token)
    end
  end

  def email_verification_token
    generate_token_for(:email_verification)
  end

  def verify_email!
    update!(verified: true)
  end
end
