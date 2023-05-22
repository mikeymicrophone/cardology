class PasswordsController < Devise::PasswordsController
  skip_before_action :verify_authenticity_token, if: -> { request.domain == 'lifeelevated.life' }

  def after_sending_reset_password_instructions_path_for(resource_name)
    root_url(message: "Your email will arrive momentarily.")
  end
end
