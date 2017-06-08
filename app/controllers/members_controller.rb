class MembersController < ApplicationController
  skip_before_action :verify_authenticity_token, :if => lambda { request.domain == 'lifeelevated.life' }

  def create
    if @member = Member.find_by_email(member_params[:email])
      sign_in @member
      redirect_to root_url
      return
    end

    @member = Member.new member_params
    @member.password = Member.generate_password
    @member.password_confirmation = @member.password
    @member.save
    sign_in @member
    redirect_to birthday_path @member.birthday, :member_id => @member.id, :scroll_to_top => true
  end

  def update
    @member = Member.find params[:id]
    @member.update_attributes member_params
    respond_to do |format|
      format.html { redirect_to(birthday_path(@member.birthday, :member_id => @member.id)) }
      format.js do
        if @member.zodiac_sign.present?
          @alternative_card_location = member_assign_zodiac_path(:id => @member.id, :member => {:zodiac_sign => nil})
          @link_method = :put
          @header_text = marketing_text('card_previews', 'your', 'personality', 'header')
          @header_subtitle = ENV['PERSONALITY_CARD_SUBTITLE']
          @link_text = marketing_text('card_previews', 'your', 'personality', 'button_alt')
          @structural_role = 'personality_card_for'
          @birthday = @member.birthday
          @birthday.zodiac_sign = @member.zodiac_sign&.intern
          @card = @birthday.personality_card
          @card_explanation = @card.interpretations.where(:reading => :personality).last&.explanation || @card.interpretations.where(:reading => :birth).last&.explanation
          render :template => 'birthdays/replace_card.js.erb'
        else
          @birthday = @member.birthday
          render :template => 'birthdays/cusp_select.js.erb'
        end
      end
    end
  end

  private

  def member_params
    params.require(:member).permit(:birthday_id, :name, :email, :lookup_id, :zodiac_sign)
  end

end
