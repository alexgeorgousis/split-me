module User::Demoable
  extend ActiveSupport::Concern

  DEMO_DURATION = 1.hour

  included do
    after_create :schedule_demo_cleanup, if: :demo?
  end

  def minutes_remaining
    if demo?
      ((created_at + DEMO_DURATION - Time.current) / 60).to_i
    end
  end

  private
    def schedule_demo_cleanup
      CleanupDemoUserJob.set(wait: DEMO_DURATION).perform_later(id)
    end
end
