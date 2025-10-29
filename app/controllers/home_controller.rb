class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    redirect_to splits_path if authenticated?

    @demo_user = User.find_by(id: session[:demo_user_id], demo: true) if session[:demo_user_id]
  end
end
