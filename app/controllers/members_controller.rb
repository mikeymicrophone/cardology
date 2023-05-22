class MembersController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { request.domain == 'lifeelevated.life' }

  def create
    if @member = Member.find_by_email(member_params[:email])
      sign_in @member
      redirect_to root_url
      return
    end

    @member = Member.new(member_params)
    @member.password = Member.generate_password
    @member.password_confirmation = @member.password
    @member.save
    cookies[:new_registration] = true
    sign_in @member
    redirect_to birthday_path(@member.birthday, member_id: @member.id, scroll_to_top: true)
  end

  def update
    @member = Member.find(params[:id])
    @member.update(member_params)
    respond_to do |format|
      format.html { redirect_to birthday_path(@member.birthday, member_id: @member.id) }
      format.js do
        if @member.zodiac_sign.present?
          @alternative_card_location = member_assign_zodiac_path(id: @member.id, member: { zodiac_sign: nil })
          @link_method = :put
          @header_text = 'Your Personality Card'
          @header_subtitle = ENV['PERSONALITY_CARD_SUBTITLE']
          @link_text = 'Change my Zodiac sign'
          @structural_role = 'personality_card_for'
          @birthday = @member.birthday
          @birthday.zodiac_sign = @member.zodiac_sign&.intern
          @card = @birthday.personality_card
          @card_explanation = @card.interpretations.where(reading: :personality).last&.explanation || @card.interpretations.where(reading: :birth).last&.explanation
          @querent = 'member'
          render template: 'birthdays/replace_card.js.erb'
        else
          @birthday = @member.birthday
          render template: 'birthdays/cusp_select.js.erb'
        end
      end
    end
  end

  def index
    if can?(:read, Member)
      @members = if params[:filter] == 'subscribed'
                   Member.where(subscription_status: Member.subscription_statuses['active'])
                 elsif params[:order] == 'birthday'
                   Member.joins(:birthday).order('birthdays.month', 'birthdays.day', 'birthdays.year')
                 else
                   Member.order(params[:order])
                 end.page(params[:page])
    else
      redirect_to root_url
    end
  end

  private

  def member_params
    params.require(:member).permit(:birthday_id, :name, :email, :lookup_id, :zodiac_sign)
  end
end
