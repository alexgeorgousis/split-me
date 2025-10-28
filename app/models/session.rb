class Session < ApplicationRecord
  belongs_to :user

  after_destroy :destroy_demo_user

  private
    def destroy_demo_user
      user.destroy if user.demo?
    end
end
