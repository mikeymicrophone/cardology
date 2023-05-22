class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def after_sign_in_path_for(resource)
    birthday_path(resource.birthday, member_id: resource.id)
  end
  
  def current_ability
    @current_ability ||= Ability.new(current_member)
  end
end
