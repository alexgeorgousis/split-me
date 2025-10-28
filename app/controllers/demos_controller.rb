class DemosController < ApplicationController
  allow_unauthenticated_access

  def create
    email = "demo_#{SecureRandom.hex(8)}@example.com"
    password = SecureRandom.hex(16)

    user = User.create!(
      email_address: email,
      password: password,
      password_confirmation: password,
      demo: true
    )

    start_new_session_for(user)
    redirect_to splits_path
  end
end
