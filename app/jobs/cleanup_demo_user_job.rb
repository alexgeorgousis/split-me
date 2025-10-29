class CleanupDemoUserJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user&.demo?

    user.destroy
  end
end
