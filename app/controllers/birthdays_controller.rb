class BirthdaysController < ApplicationController
  skip_before_action :verify_authenticity_token, :if => lambda { request.domain == 'lifeelevated.life' }
  before_action :redirect_customer, :only => :index

  def index
    @birthdays = Birthday.all
  end

  def show
    @member = current_member || Member.find(params[:member_id])
    @birthday = Birthday.find params[:id]
    @birth_card = @birthday.birth_card
    if @birthday == @member.birthday
      @pronoun = "Your"
      @querent = "your"
      @birthday.zodiac_sign = @member&.zodiac_sign&.intern
    else
      @pronoun = "Their"
      @querent = "their"
    end
    if @birthday.astrological_sign.is_cusp?
      @personality_card = nil
    else
      @personality_card = @birthday.personality_card
    end
    @personality_card_explanation = @personality_card&.interpretations&.where(:reading => :personality)&.last&.explanation
    @personality_card_explanation ||= @personality_card&.interpretations&.where(:reading => :birth)&.last&.explanation
    @scroll_to_top = params[:scroll_to_top]
  end
  
  def replace_card
    @birthday = Birthday.find params[:id]
    @card = case params[:reading_type]
    when 'personality'
      @alternative_card_location = replace_card_birthday_path(current_member.birthday, :reading_type => 'personality')
      @header_text = view_context.marketing_text('card_previews', 'your', 'personality', 'header')
      @header_subtitle = ENV['PERSONALITY_CARD_SUBTITLE']
      @link_text = view_context.marketing_text('card_previews', 'your', 'personality', 'button')
      @structural_role = 'personality_card_for'
      @cusp = @birthday.zodiac_for_birthday
      if @cusp.leader == current_member.zodiac_sign.intern
        @birthday.zodiac_sign = @cusp.follower
        if @birthday == current_member.birthday
          current_member.update_attribute :zodiac_sign, @cusp.follower
        end
      else
        @birthday.zodiac_sign = @cusp.leader
        if @birthday == current_member.birthday
          current_member.update_attribute :zodiac_sign, @cusp.leader
        end
      end
      @card_explanation = @birthday.personality_card.interpretations.where(:reading => :personality).last&.explanation || @birthday.personality_card.interpretations.where(:reading => :birth).last&.explanation
      @birthday.personality_card
    end
    @card_explanation ||= @card.interpretations.where(:reading => :yearly).last&.explanation
    render :template => 'birthdays/replace_card.js.erb'
  end

  def new
    @date = rand((50.years.ago)..20.years.ago)
    if current_member
      @goal = view_context.marketing_text('additional_lookup', 'subheader')
      @instructions = view_context.marketing_text('additional_lookup', 'instructions')
    else
      @goal = view_context.marketing_text('new_players', 'subheader')
      @instructions = view_context.marketing_text('new_players', 'instructions')
    end
  end

  def mine
    redirect_to current_member.birthday
  end

  def create
    @birthday = Birthday.find_or_create_by :year => birthday_params['date(1i)'], :month => birthday_params['date(2i)'], :day => birthday_params['date(3i)']
    @lookup = Lookup.create :birthday => @birthday, :ip_address => request.remote_ip
    @birth_card = @birthday.birth_card
    @birth_card_explanation = @birth_card.interpretations.where(:reading => :birth).last&.explanation
    if current_member
      redirect_to birthday_path(@birthday, :navigation_shown => true)
    else
      render :template => 'birthdays/member_form'
    end
  end

  def second_try
    @date = rand((50.years.ago)..20.years.ago)
    @goal = view_context.marketing_text('new_players', 'subheader')
    @instructions = view_context.marketing_text('new_players', 'instructions')
    @email = params[:member][:email]
    @password_explanation = view_context.marketing_text('returning_players', 'password_wrong').html_safe
    render 'new.html.erb'
  end

  def personality_for_zodiac
    @birthday = Birthday.find params[:id]
    @birthday.zodiac_sign = params[:zodiac_sign].intern
    @card = @birthday.personality_card
    @header_text = view_context.marketing_text('card_previews', 'their', 'personality', 'header')
    @card_explanation = @card.interpretations.where(:reading => :personality).last&.explanation || @card.interpretations.where(:reading => :birth).last&.explanation
    render :template => 'birthdays/replace_card.js.erb'
  end

  def birthday_params
    params.require(:birthday).permit('date(1i)', 'date(2i)', 'date(3i)')
  end

  def redirect_customer
    redirect_to :action => :new
  end
end
