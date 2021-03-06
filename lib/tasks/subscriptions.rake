namespace :subscriptions do
  desc 'Retrieve Braintree id codes for each subscription'
  task :identify => :environment do
    subscriptions = Braintree::Subscription.search do |search|
      search.plan_id.is ENV['BRAINTREE_SUBSCRIPTION_PLAN']
    end
    
    subscriptions.each do |subscription|
      customer_id = subscription.transactions.last.customer_details.id rescue nil
      @member = Member.where(:braintree_id => customer_id).take
      if @member
        if @member.subscriptions.include? subscription.id
          puts "subscription #{subscription.id} known"
        else
          @member.subscriptions << subscription.id
          @member.save
          puts "subscription #{subscription.id} assigned to #{@member.email}"
        end
      end
    end
  end
  
  desc 'Determine if any subscriptions are past due'
  task :audit => :environment do
    Member.all.each do |member|
      member.verify_subscription_payments_current rescue nil
    end
  end
  
  desc 'Remind past due members'
  task :remind => :environment do
    Member.past_due.each do |member|
      time_elapsed = (Date.today - member.due_date.to_date).to_i
      case time_elapsed
      when 3
        member.notify_past_due 'unresolved'
      when 10
        member.notify_past_due 'late'
      when 25
        member.notify_past_due 'over'
      when 27
        member.cancel_subscription!
      end
    end
  end
  
  desc 'Change price of subscriptions'
  task :price_change => :environment do
    gateway = Braintree::Gateway.new(
      :environment => :production,
      :merchant_id => ENV["BT_MERCHANT_ID"],
      :public_key => ENV["BT_PUBLIC_KEY"],
      :private_key => ENV["BT_PRIVATE_KEY"]
    )
    
    Member.players_club_subscribed.find_each do |member|
      member.subscriptions.each do |subscription_id|
        update_result = gateway.subscription.update(subscription_id, :price => '2.97')
        puts update_result.inspect
      end
    end
  end
end
