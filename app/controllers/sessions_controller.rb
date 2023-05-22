class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, if: -> { request.domain == 'lifeelevated.life' }
  before_action :acknowledge_time_zone

  def auth_options
    { scope: resource_name, recall: "birthdays#second_try" }
  end

  def acknowledge_time_zone
    if params[:time_zone].present?
      params[:time_zone] =~ /([+-]\d+):\d+/
      session[:time_zone] = Regexp.last_match(1).to_i
    end
  end
end
