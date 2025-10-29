class DemosController < ApplicationController
  allow_unauthenticated_access

  def create
    user = find_or_create_demo_user
    start_new_session_for user
    redirect_to splits_path
  end

  private
    def find_or_create_demo_user
      if existing_user = find_demo_user
        return existing_user
      end

      create_demo_user
    end

    def find_demo_user
      if session[:demo_user_id]
        User.find_by(id: session[:demo_user_id], demo: true)
      end
    end

    def create_demo_user
      email = "demo_#{SecureRandom.hex(8)}@example.com"
      password = SecureRandom.hex(16)

      user = User.create!(
        email_address: email,
        password: password,
        password_confirmation: password,
        demo: true
      )

      session[:demo_user_id] = user.id
      user
    end
end
