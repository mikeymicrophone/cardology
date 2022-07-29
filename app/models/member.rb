class Member < ApplicationRecord
  after_create :deliver_temporary_password
  before_update :acknowledge_subscription_status_change
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  enum :zodiac_sign => [:aries, :taurus, :gemini, :cancer, :leo, :virgo, :libra, :scorpio, :sagittarius, :capricorn, :aquarius, :pisces]
  enum :subscription_status => [:active, :past_due, :canceled, :upgraded]
  attr_default :subscriptions, []
  serialize :subscriptions
  attr_default :campaigns, []
  serialize :campaigns
  attr_accessor :days_past_due

  belongs_to :birthday
  belongs_to :lookup
  has_many :celestials
  
  scope :players_club_subscribed, lambda { where :subscription_status => 'active' }
  scope :players_club_mailing, lambda { where "campaigns like '%players_club%'" }
  
  scope :past_due, lambda { where :subscription_status => 'past_due' }
  
  paginates_per 52
  
  def celestials_transitions
    quartets = []
    celestials.each do |celestial|
      celestial.birthday.triples_for_year.each do |date, planet, card|
        quartets << [date, planet, card, celestial]
      end
    end
    quartets
  end
  
  def add_to_players_club_campaign
    client = GetResponse::Api.new
    traits = {
      :name => name,
      :email => email,
      :campaign => {:campaignId => ENV['GETRESPONSE_PLAYERS_CLUB_ID']},
      :customFieldValues => [{:customFieldId => ENV['GETRESPONSE_BIRTHDATE_ID'], :value => [birthday.birthdate_string]}]
    }
    client.contacts.create traits
  end
  
  def remove_from_players_club_campaign
    get_response_api.remove_contact players_club_email_membership
  end
  
  def players_club_email_membership
    get_response_api.contacts(:email_address => email, :campaign_id => ENV['GETRESPONSE_PLAYERS_CLUB_ID']).first['contactId']
  end
  
  def mail_campaigns
    client = GetResponse::Api.new
    lists = client.search_contacts.retrieve(:email => email)
    lists.body.map { |result| result['name'] }
  end
  
  def get_response_api
    @client ||= GetResponseApi::Client.new ENV['GETRESPONSE_API_TOKEN']
  end
  
  def email_lists
    get_response_api.contacts(:email_address => email).map { |contact| contact['campaign']['name'] rescue nil }.compact
  end
  
  def add_to_players_club_salon
    MemberMailer.with(:member => self).salon.deliver
  end
  
  def subscribed?
    ['active', 'past_due'].include? subscription_status
  end
  
  def on_mailing_list?
    campaigns.include? ENV['GETRESPONSE_CAMPAIGN_NAME']
  end
  
  # def active_for_authentication?
  #   subscribed? || on_mailing_list? || (created_at > 2.days.ago)
  # end
  
  def acknowledge_subscription_status_change
    if subscription_status_changed? :from => 'active', :to => 'past_due'
      PaymentMailer.with(:member => self).missed.deliver
      self.due_date = @days_past_due.days.ago
    end
  end
  
  def subscription_past_due?
    subscription_status == 'past_due'
  end
  
  def verify_subscription_payments_current
    subscriptions.each do |subscription_id|
      subscription = Braintree::Subscription.find subscription_id
      @days_past_due = subscription.days_past_due
      update_attributes :subscription_status => subscription.status.parameterize.underscore
    end
  end
  
  def notify_past_due timing
    PaymentMailer.with(:member => self, :timing => timing).unresolved.deliver
  end
  
  def cancel_subscription! # this may need to be revisited if we allow concurrent subscriptions for various membership features
    # perhaps it should take an argument indicating which plan is being unsubscribed from
    subscriptions.each do |subscription_id|
      @cancellation_result = Braintree::Subscription.cancel subscription_id
    end
    update_attributes :subscription_status => 'canceled', :subscriptions => [] if @cancellation_result.success?
    remove_from_players_club_campaign
  end
  
  def account_age
    ((Time.now - created_at) / 1.day).floor
  end
  
  def account_hour
    (((Time.now - created_at) / 1.hour) - 24*account_age).round
  end
  
  def self.generate_password
    ENV['INITIAL_PASSWORD']
  end
  
  def deliver_temporary_password
    MemberMailer.with(:member => self).temporary_password.deliver
  end
end
