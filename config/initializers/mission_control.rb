MissionControl::Jobs.base_controller_class = "ActionController::Base"

if Rails.env.development?
  MissionControl::Jobs.http_basic_auth_enabled = false
elsif Rails.env.production?
  MissionControl::Jobs.http_basic_auth_user = ENV["MISSION_CONTROL_USER"]
  MissionControl::Jobs.http_basic_auth_password = ENV["MISSION_CONTROL_PASSWORD"]
end
