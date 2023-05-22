class SubscriptionsController < ApplicationController
  def new
    render json: { client_token: Braintree::ClientToken.generate }
  end

  def create
    @member = Member.find(params[:member_id])
    return if params[:payment_method_nonce].blank?

    customer_creation = Braintree::Customer.create(
      first_name: @member.name,
      email: @member.email,
      payment_method_nonce: params[:payment_method_nonce]
    )

    if customer_creation.success?
      @member.braintree_id = customer_creation.customer.id
      token = customer_creation.customer.payment_methods.first.token

      subscription_creation = Braintree::Subscription.create(
        payment_method_token: token,
        plan_id: ENV['BRAINTREE_SUBSCRIPTION_PLAN']
      )

      if subscription_creation.success?
        @member.subscription_status = 'active'
        @member.subscriptions << subscription_creation.subscription.id
        @member.add_to_players_club_campaign
        @message = view_context.marketing_text('subscription', 'transaction', 'succeeded')
      else
        @message = view_context.marketing_text('subscription', 'transaction', 'failed')
      end
    else
      p customer_creation.errors
    end

    @member.save
  end

  def upgrade
    customer = Braintree::Customer.find(current_member.braintree_id)
    token = customer.payment_methods.first.token

    subscription_creation = Braintree::Subscription.create(
      payment_method_token: token,
      plan_id: ENV['BRAINTREE_SALON_SUBSCRIPTION_PLAN']
    )

    if subscription_creation.success?
      @member = current_member
      @member.subscription_status = 'upgraded'
      @member.subscriptions << subscription_creation.subscription.id
      @member.add_to_players_club_salon
      @message = view_context.marketing_text('subscription', 'upgrade', 'succeeded')
    end
  end

  def update
    @member = Member.find(params[:member_id])
    @customer = Braintree::Customer.find(@member.braintree_id)
    Rails.logger.info('About to update payment method:')

    customer_update = Braintree::Customer.update(
      @customer.id,
      payment_method_nonce: params[:payment_method_nonce]
    )

    if customer_update.success?
      token = customer_update.customer.payment_methods.sort_by(&:created_at).last.token
      Rails.logger.info("The payment method was updated to #{token}.")

      Rails.logger.info('About to update the subscription:')
      @member.subscriptions.each do |subscription_id|
        subscription_update = Braintree::Subscription.update(
          subscription_id,
          payment_method_token: token
        )

        if subscription_update.success?
          Rails.logger.info('The subscription was updated.')
          Braintree::Subscription.retry_charge(subscription_id)
          @member.update_attribute(:subscription_status, 'active')
          @member.add_to_players_club_campaign
          @message = view_context.marketing_text('subscription', 'update', 'succeeded')
        end
      end
    end

    @message ||= view_context.marketing_text('subscription', 'update', 'failed')

    respond_to do |format|
      format.html do
        flash[:notice] = @message
        redirect_to @member.birthday
      end
      format.json do
        render json: { message: @message }
      end
    end
  end

  def manage
    @member = Member.find(params[:member_id])
  end

  def cancel
    @member = Member.find(params[:member_id])

    @member.subscriptions.each do |subscription_id|
      cancellation_result = Braintree::Subscription.cancel(subscription_id)
      Rails.logger.info(cancellation_result.inspect)
    end

    @member.subscriptions = []
    @member.subscription_status = 'canceled'
    @member.save

    redirect_to @member.birthday
  end
end
