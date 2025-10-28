class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    redirect_to splits_path if authenticated?
  end
end
