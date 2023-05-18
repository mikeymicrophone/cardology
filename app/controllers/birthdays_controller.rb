class BirthdaysController < ApplicationController
  skip_before_action :verify_authenticity_token, :if => lambda { ['lifeelevated.life', 'thesourcecards.com', 'herokuapp.com'].include? request.domain }
  before_action :redirect_customer, :only => :index
  
  def index
    @birthdays = Birthday.all
  end
  
  def show
    Time.zone = ActiveSupport::TimeZone[session[:time_zone]] if session[:time_zone]
    @member = current_member || Member.find(params[:member_id])
    @birthday = Birthday.find params[:id]
    @birth_card = @birthday.birth_card
    if @birthday == @member.birthday
      @pronoun = "Your"
      @birthday.zodiac_sign = @member&.zodiac_sign&.intern
      @querent = 'member'
    else
      @pronoun = "Their"
      @querent = 'acquaintance'
    end
    if @birthday.astrological_sign.is_cusp?
      @personality_card = nil
    else
      @personality_card = @birthday.personality_card
    end
    @personality_card_explanation = @personality_card&.interpretations&.where(:reading => :personality)&.last&.explanation
    @personality_card_explanation ||= @personality_card&.interpretations&.where(:reading => :birth)&.last&.explanation
    @scroll_to_top = params[:scroll_to_top]
    @time_until_midnight = Time.now.seconds_until_end_of_day
  end
  
  def replace_card
    @birthday = Birthday.find params[:id]
    @card = case params[:reading_type]
    when 'personality'
      @alternative_card_location = replace_card_birthday_path(current_member.birthday, :reading_type => 'personality')
      @header_text = 'Your Personality Card'
      @header_subtitle = ENV['PERSONALITY_CARD_SUBTITLE']
      @link_text = "Jump Over the Cusp"
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
  
  def browse
    @member = current_member || Member.find(params[:member_id])
    @birthday = Birthday.find params[:id]
    if params[:day] == 'tomorrow'
      @card = @birthday.card_for_tomorrow
      @header = view_context.marketing_text('heading', 'member', 'tomorrow', 'header')
      @subheader = "For #{Date.tomorrow.strftime("%-m/%-d/%Y")} #{view_context.link_to '[yesterday]', browse_birthday_path(@birthday, :day => 'yesterday', :member_id => @member.id), :remote => true} #{view_context.link_to '[today]', browse_birthday_path(@birthday, :day => 'today', :member_id => @member.id), :remote => true}<br>#{view_context.marketing_text('heading', 'member', 'tomorrow', 'subheader')}".html_safe
    elsif params[:day] == 'today'
      @card = @birthday.card_for_today
      @header = view_context.marketing_text('heading', 'member', 'daily', 'header')
      @subheader = "For #{Date.current.strftime("%-m/%-d/%Y")} #{view_context.link_to '[yesterday]', browse_birthday_path(@birthday, :day => 'yesterday', :member_id => @member.id), :remote => true} #{view_context.link_to '[tomorrow]', browse_birthday_path(@birthday, :day => 'tomorrow', :member_id => @member.id), :remote => true}<br>#{view_context.marketing_text('heading', 'member', 'daily', 'subheader')}".html_safe
    elsif params[:day] == 'yesterday'
      @card = @birthday.card_for_yesterday
      @header = view_context.marketing_text('heading', 'member', 'yesterday', 'header')
      @subheader = "For #{Date.yesterday.strftime("%-m/%-d/%Y")} #{view_context.link_to '[today]', browse_birthday_path(@birthday, :day => 'today', :member_id => @member.id), :remote => true} #{view_context.link_to '[tomorrow]', browse_birthday_path(@birthday, :day => 'tomorrow', :member_id => @member.id), :remote => true}<br>#{view_context.marketing_text('heading', 'member', 'yesterday', 'subheader')}".html_safe
    end
  end
  
  def new
    @date = rand((50.years.ago)..20.years.ago)
    if current_member
      @goal = view_context.marketing_text('new_teammates', 'subheader')
      @instructions = view_context.marketing_text('new_teammates', 'instructions')
    else
      @goal = view_context.marketing_text('new_players', 'subheader')
      @instructions = view_context.marketing_text('new_players', 'instructions')
      
      if cookies[:new_registration] == 'true'
        @password_explanation = view_context.marketing_text('returning_players', 'password_hint')
        cookies[:new_registration] = false
      end
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
    if params[:source_cards]
      redirect_to access_delivery_path(@birthday, :spread_direction => params[:spread_direction])
    else
      if current_member
        redirect_to birthday_path(@birthday, :navigation_shown => true, :member_id => current_member.id)
      else
        render :template => 'birthdays/member_form'
      end
    end
  end
  
  def second_try
    @date = rand((50.years.ago)..20.years.ago)
    @goal = view_context.marketing_text('new_players', 'subheader')
    @instructions = view_context.marketing_text('new_players', 'instructions')
    @email = params[:member][:email]
    @password_explanation = view_context.marketing_text('password', 'incorrect').html_safe
    render 'new.html.erb'
  end
  
  def personality_for_zodiac
    @birthday = Birthday.find params[:id]
    @birthday.zodiac_sign = params[:zodiac_sign].intern
    @card = @birthday.personality_card
    @header_text = 'Their Personality Card'
    @querent = 'acquaintance'
    if params[:source_cards]
      render :template => 'birthdays/display_card'
    else
      @card_explanation = @card.interpretations.where(:reading => :personality).last&.explanation || @card.interpretations.where(:reading => :birth).last&.explanation
      render :template => 'birthdays/replace_card'
    end
  end
  
  def birthday_params
    params.require(:birthday).permit('date(1i)', 'date(2i)', 'date(3i)')
  end
  
  def redirect_customer
    redirect_to :action => :new
  end
end
